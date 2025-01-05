// The Swift Programming Language
// https://docs.swift.org/swift-book
import Combine
import Foundation
import HotReloadSwiftUITransferProtocol
import MapKit
import SwiftUI

class RenderState<Env: Codable>: ObservableObject {
    @Published var data: RenderData?
    private var cancellables = Set<AnyCancellable>()

    var server: LocalServer?
    @MainActor private var environmentUpdater: ((Env) -> Void)?

    init(id _: String, server: LocalServer, environmentUpdater: @escaping (Env) -> Void) {
        self.server = server
        self.environmentUpdater = environmentUpdater

        server.dataPublisher
            .sink { [weak self] jsonString in
                if jsonString.isEmpty {
                    self?.handleDisconnect()
                    return
                }

                do {
                    guard let data = jsonString.data(using: .utf8) else { return }

                    if let transferMessage = try? JSONDecoder().decode(TransferMessage.self, from: data) {
                        self?.handleTransferMessage(transferMessage)
                    }
                } catch {
                    self?.handleError(jsonString, error)
                }
            }
            .store(in: &cancellables)
    }

    private func handleDisconnect() {
        DispatchQueue.main.async {
            self.data = nil
            print("接收到空字符串，意味着断联，将数据置空")
        }
    }

    private func handleTransferMessage(_ message: TransferMessage) {
        switch message {
        case let .render(renderData):
            handleRenderData(renderData)
        case let .environmentUpdate(container):
            handleEnvironmentUpdate(container)
        case .initialArg(_), .interactive:
            break
        }
    }

    private func handleRenderData(_ renderData: RenderData) {
        DispatchQueue.main.async {
            self.data = renderData
        }
    }

    private func handleEnvironmentUpdate(_ container: EnvironmentContainer) {
        guard let data = container.data.data(using: .utf8) else { return }

        do {
            let decodedValue = try JSONDecoder().decode(Env.self, from: data)
            Task { @MainActor in
                environmentUpdater?(decodedValue)
            }
        } catch {
            print("更新环境值失败: \(error)")
        }
    }

    private func handleError(_ jsonString: String, _ error: Error) {
        DispatchQueue.main.async {
            self.data = nil
            print("解码 JSON 失败: \(jsonString), 错误: \(error)")
        }
    }
}

public struct HotReloadSwiftUIRunner<Inner: View, Arg: Codable, Env: Codable>: View {
    let id: String
    let arg: Arg
    let content: Inner
    let environmentUpdater: (Env) -> Void

    #if DEBUG
        @StateObject var state: RenderState<Env>
    #endif

    @State private var gradientStart = UnitPoint(x: -1, y: 0.5)
    @State private var gradientEnd = UnitPoint(x: 0, y: 0.5)

    public init(
        id: String,
        arg: Arg,
        environment: Env?,
        environmentUpdater: @escaping (Env) -> Void,
        @ViewBuilder content: (_ arg: Arg) -> Inner
    ) {
        self.id = id
        self.arg = arg
        self.content = content(arg)
        self.environmentUpdater = environmentUpdater

        #if DEBUG
            _state = StateObject(wrappedValue: RenderState<Env>(
                id: id,
                server: LocalServer(initialArg: arg, environment: environment),
                environmentUpdater: environmentUpdater
            ))
        #endif
    }

    public var body: some View {
        VStack(spacing: 0) {
            Group {
                Text("当前渲染内容来自： \(state.data?.tree == nil ? "native" : "network")")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 5)
            .background(
                Group {
                    if state.data?.tree == nil {
                        Color.white
                    } else {
                        LinearGradient(
                            colors: [.blue, .purple, .pink],
                            startPoint: gradientStart,
                            endPoint: gradientEnd
                        )
                        .onAppear {
                            withAnimation(
                                .linear(duration: 2)
                                    .repeatForever(autoreverses: false)
                            ) {
                                gradientStart = UnitPoint(x: 1, y: 0.5)
                                gradientEnd = UnitPoint(x: 2, y: 0.5)
                            }
                        }
                    }
                }
            )
            Group {
                if let node = state.data?.tree {
                    buildView(from: node)
                } else {
                    content
                }
            }
        }
        .onDisappear {
            state.server?.close()
        }
    }

    @ViewBuilder
    private func buildView(from node: Node) -> some View {
        let view = switch node.type {
        case .text:
            buildTextView(from: node)
        case .button:
            buildButtonView(from: node)
        case .vStack:
            buildVStackView(from: node)
        case .hStack:
            buildHStackView(from: node)
        case .divider:
            buildDividerView()
        case .spacer:
            buildSpacerView(from: node)
        case .tupleContainer:
            buildTupleContainerView(from: node)
        case .image:
            buildImageView(from: node)
        default:
            AnyView(EmptyView())
        }

        // 应用修饰符
        if let modifiers = node.modifiers {
            modifiers.reduce(view) { currentView, modifier in
                applyModifier(currentView, modifier)
            }
        } else {
            view
        }
    }

    private func buildTextView(from node: Node) -> AnyView {
        AnyView(Text(node.data["text"] ?? ""))
    }

    private func buildButtonView(from node: Node) -> AnyView {
        let id = node.data["id"] ?? ""
        return AnyView(
            Button(action: {
                Task {
                    await state.server?.sendInteractiveData(
                        InteractiveData(id: id, type: .tap)
                    )
                }
            }) {
                if let child = node.children?.first {
                    buildView(from: child)
                } else {
                    Text(node.data["title"] ?? "")
                }
            }
        )
    }

    private func buildVStackView(from node: Node) -> AnyView {
        if let children = node.children {
            AnyView(
                VStack(
                    alignment: parseHorizontalAlignment(node.data["alignment"]),
                    spacing: CGFloat(Float(node.data["spacing"] ?? "5") ?? 0)
                ) {
                    ForEach(children, id: \.id) { child in
                        buildView(from: child)
                    }
                }
            )
        } else {
            AnyView(EmptyView())
        }
    }

    private func buildHStackView(from node: Node) -> AnyView {
        if let children = node.children {
            AnyView(
                HStack(
                    alignment: parseVerticalAlignment(node.data["alignment"]),
                    spacing: CGFloat(Float(node.data["spacing"] ?? "5") ?? 0)
                ) {
                    ForEach(children, id: \.id) { child in
                        buildView(from: child)
                    }
                }
            )
        } else {
            AnyView(EmptyView())
        }
    }

    private func buildDividerView() -> AnyView {
        AnyView(Divider())
    }

    private func buildSpacerView(from node: Node) -> AnyView {
        if let minLengthStr = node.data["minLength"] {
            AnyView(Spacer(minLength: CGFloat(Float(minLengthStr) ?? 0)))
        } else {
            AnyView(Spacer())
        }
    }

    private func buildTupleContainerView(from node: Node) -> AnyView {
        if let children = node.children {
            AnyView(TupleView(children.map { child in
                buildView(from: child)
            }))
        } else {
            AnyView(EmptyView())
        }
    }

    private func buildImageView(from node: Node) -> AnyView {
        let image = if let imageName = node.data["imageName"], !imageName.isEmpty {
            Image(imageName)
        } else if let systemName = node.data["systemName"], !systemName.isEmpty {
            Image(systemName: systemName)
        } else {
            Image(systemName: "questionmark")
        }

        return AnyView(
            image
        )
    }

    private func applyModifier(_ view: AnyView, _ modifier: Node.Modifier) -> AnyView {
        switch modifier.type {
        case .frame:
            if case let .frame(frameData) = modifier.data {
                return AnyView(view.modifier(FrameViewModifier(frameData: frameData)))
            }
        case .padding:
            if case let .padding(paddingData) = modifier.data {
                return AnyView(view.modifier(PaddingViewModifier(paddingData: paddingData)))
            }
        case .clipShape:
            if case let .clipShape(clipShapeData) = modifier.data {
                return AnyView(view.modifier(ClipShapeViewModifier(clipShapeData: clipShapeData)))
            }
        case .foregroundStyle:
            if case let .foregroundStyle(foregroundStyleData) = modifier.data {
                return AnyView(view.modifier(ForegroundStyleViewModifier(foregroundStyleData: foregroundStyleData)))
            }
        case .labelStyle:
            if case let .labelStyle(labelStyleData) = modifier.data {
                return AnyView(view.modifier(LabelStyleViewModifier(labelStyleData: labelStyleData)))
            }
        case .font:
            if case let .font(fontData) = modifier.data {
                return AnyView(view.modifier(FontViewModifier(fontData: fontData)))
            }
        }
        return view
    }

    private struct FrameViewModifier: ViewModifier {
        let frameData: Node.FrameData

        func body(content: Content) -> some View {
            content.frame(
                width: frameData.width,
                height: frameData.height,
                alignment: parseAlignment(frameData.alignment)
            )
        }

        private func parseAlignment(_ str: String?) -> SwiftUI.Alignment {
            guard let str = str else { return .center }
            switch str {
            case "topLeading": return .topLeading
            case "top": return .top
            case "topTrailing": return .topTrailing
            case "leading": return .leading
            case "trailing": return .trailing
            case "bottomLeading": return .bottomLeading
            case "bottom": return .bottom
            case "bottomTrailing": return .bottomTrailing
            default: return .center
            }
        }
    }

    private struct PaddingViewModifier: ViewModifier {
        let paddingData: Node.PaddingData

        func body(content: Content) -> some View {
            content.padding(parseEdges(paddingData.edges), paddingData.length)
        }

        private func parseEdges(_ str: String) -> SwiftUI.Edge.Set {
            switch str {
            case "horizontal": return .horizontal
            case "vertical": return .vertical
            case "all": return .all
            case "top": return .top
            case "leading": return .leading
            case "bottom": return .bottom
            case "trailing": return .trailing
            default:
                let edges = str.split(separator: ",")
                var result: SwiftUI.Edge.Set = []
                for edge in edges {
                    switch edge {
                    case "top": result.insert(.top)
                    case "leading": result.insert(.leading)
                    case "bottom": result.insert(.bottom)
                    case "trailing": result.insert(.trailing)
                    default: break
                    }
                }
                return result
            }
        }
    }

    private struct ClipShapeViewModifier: ViewModifier {
        let clipShapeData: Node.ClipShapeData

        func body(content: Content) -> some View {
            switch clipShapeData.shapeType {
            case "circle":
                content.clipShape(Circle())
            case "rectangle":
                content.clipShape(Rectangle())
            case "capsule":
                content.clipShape(Capsule())
            default:
                content
            }
        }
    }

    private struct ForegroundStyleViewModifier: ViewModifier {
        let foregroundStyleData: Node.ForegroundStyleData

        func body(content: Content) -> some View {
            let color: SwiftUI.Color = {
                switch foregroundStyleData.color {
                case "yellow": return .yellow
                case "gray": return .gray
                case "primary": return .primary
                case "secondary": return .secondary
                case "tint": return .accentColor
                default: return .primary
                }
            }()
            content.foregroundStyle(color)
        }
    }

    private struct LabelStyleViewModifier: ViewModifier {
        let labelStyleData: Node.LabelStyleData

        func body(content: Content) -> some View {
            let style: any SwiftUI.LabelStyle = {
                switch labelStyleData.style {
                case "iconOnly":
                    return .iconOnly
                case "titleOnly":
                    return .titleOnly
                case "titleAndIcon":
                    return .titleAndIcon
                default:
                    return .automatic
                }
            }()
            AnyView(content.labelStyle(style))
        }
    }

    private struct FontViewModifier: ViewModifier {
        let fontData: Node.FontData

        func body(content: Content) -> some View {
            let font: SwiftUI.Font = {
                switch fontData.style {
                case "title": return .title
                case "title2": return .title2
                case "subheadline": return .subheadline
                case "body": return .body
                default: return .body
                }
            }()
            content.font(font)
        }
    }

    private func parseHorizontalAlignment(_ str: String?) -> HorizontalAlignment {
        guard let str = str else { return .center }
        switch str {
        case "leading": return .leading
        case "trailing": return .trailing
        default: return .center
        }
    }

    private func parseVerticalAlignment(_ str: String?) -> VerticalAlignment {
        guard let str = str else { return .center }
        switch str {
        case "top": return .top
        case "bottom": return .bottom
        default: return .center
        }
    }
}

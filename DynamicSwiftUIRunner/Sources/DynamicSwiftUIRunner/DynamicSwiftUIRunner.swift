// The Swift Programming Language
// https://docs.swift.org/swift-book
import Combine
import DynamicSwiftUITransferProtocol
import Foundation
import MapKit
import SwiftUI

class RenderState: ObservableObject {
    @Published var data: RenderData?
    private var cancellables = Set<AnyCancellable>()
    
    private var server: LocalServer?
    
    init(id: String, server: LocalServer) {
        self.server = server
        
        server.dataPublisher
            .sink { [weak self] jsonString in
                if jsonString.isEmpty {
                    DispatchQueue.main.async {
                        self?.data = nil
                        print("接收到空字符串，意味着断联，将数据置空")
                    }
                }
                do {
                    guard let data = jsonString.data(using: .utf8) else {
                        throw NSError(domain: "RenderState", code: -1,
                                      userInfo: [NSLocalizedDescriptionKey: "无法将字符串转换为数据"])
                    }
                    
                    if let transferMessage = try? JSONDecoder().decode(TransferMessage.self, from: data) {
                        switch transferMessage {
                        case .renderData(let renderData):
                            DispatchQueue.main.async {
                                self?.data = renderData
                            }
                        case .initialArg, .interactiveData:
                            // Runner 端不需要处理这些消息类型
                            break
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self?.data = nil
                        print("解码 JSON 失败: \(jsonString), 错误: \(error)")
                    }
                }
            }
            .store(in: &cancellables)
    }
}

public struct DynamicSwiftUIRunner<Inner: View, Arg: Codable>: View {
    let id: String
    let arg: Arg
    let content: Inner
    #if DEBUG
    @StateObject private var state: RenderState
    private let server: LocalServer
    #endif
    
    @State private var gradientStart = UnitPoint(x: -1, y: 0.5)
    @State private var gradientEnd = UnitPoint(x: 0, y: 0.5)
    
    public init(
        id: String,
        arg: Arg,
        @ViewBuilder content: (_ arg: Arg) -> Inner
    ) {
        self.id = id
        self.arg = arg
        self.content = content(arg)
        #if DEBUG
        let server = LocalServer(initialArg: arg)
        _state = StateObject(wrappedValue: RenderState(id: id, server: server))
        self.server = server
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
    }
    
    @ViewBuilder
    private func buildView(from node: Node) -> some View {
        let view = switch node.type {
        case .text:
            AnyView(Text(node.data["text"] ?? ""))
        case .button:
            AnyView(Button(node.data["title"] ?? "") {
                let interactiveData = InteractiveData(id: node.id, type: .tap)
                Task {
                    await server.sendInteractiveData(interactiveData)
                }
            })
        case .vStack:
            if let children = node.children {
                AnyView(VStack(alignment: parseHorizontalAlignment(node.data["alignment"]), spacing: CGFloat(Float(node.data["spacing"] ?? "5") ?? 0)) {
                    ForEach(children, id: \.id) { child in
                        buildView(from: child)
                    }
                })
            } else {
                AnyView(EmptyView())
            }
        case .hStack:
            if let children = node.children {
                AnyView(HStack(alignment: parseVerticalAlignment(node.data["alignment"]), spacing: CGFloat(Float(node.data["spacing"] ?? "5") ?? 0)) {
                    ForEach(children, id: \.id) { child in
                        buildView(from: child)
                    }
                })
            } else {
                AnyView(EmptyView())
            }
        case .divider:
            AnyView(Divider())
        case .spacer:
            if let minLengthStr = node.data["minLength"] {
                AnyView(Spacer(minLength: CGFloat(Float(minLengthStr) ?? 0)))
            } else {
                AnyView(Spacer())
            }
        case .tupleContainer:
            if let children = node.children {
                AnyView(TupleView(children.map { child in
                    buildView(from: child)
                }))
            } else {
                AnyView(EmptyView())
            }
        case .image: {
                let image = if let imageName = node.data["imageName"], !imageName.isEmpty {
                    Image(imageName)
                } else if let systemName = node.data["systemName"], !systemName.isEmpty {
                    Image(systemName: systemName)
                } else {
                    Image(systemName: "questionmark")
                }
                let imageScale: Image.Scale = {
                    switch node.data["imageScale"] {
                    case "small": return .small
                    case "large": return .large
                    default: return .medium
                    }
                }()
                let foregroundStyle: some ShapeStyle = {
                    switch node.data["foregroundStyle"] {
                    case "tint": return Color.accentColor
                    case "secondary": return Color.secondary
                    default: return Color.primary
                    }
                }()
            
                return AnyView(
                    image
                        .imageScale(imageScale)
                        .foregroundStyle(foregroundStyle)
                )
            }()
        default:
            AnyView(EmptyView())
        }
        
        // 按顺序应用所有修饰符
        if let modifiers = node.modifiers {
            modifiers.reduce(view) { currentView, modifier in
                switch modifier.type {
                case .frame:
                    if case .frame(let frameData) = modifier.data {
                        return AnyView(currentView.modifier(FrameViewModifier(frameData: frameData)))
                    }
                case .padding:
                    if case .padding(let paddingData) = modifier.data {
                        return AnyView(currentView.modifier(PaddingViewModifier(paddingData: paddingData)))
                    }
                case .clipShape:
                    if case .clipShape(let clipShapeData) = modifier.data {
                        return AnyView(currentView.modifier(ClipShapeViewModifier(clipShapeData: clipShapeData)))
                    }
                }
                return currentView
            }
        } else {
            view
        }
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

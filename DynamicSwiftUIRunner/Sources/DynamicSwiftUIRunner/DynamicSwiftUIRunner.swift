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
                do {
                    guard let data = jsonString.data(using: .utf8) else {
                        throw NSError(domain: "RenderState", code: -1,
                                      userInfo: [NSLocalizedDescriptionKey: "无法将字符串转换为数据"])
                    }
                    
                    let renderData = try JSONDecoder().decode(RenderData.self, from: data)
                    
                    DispatchQueue.main.async {
                        self?.data = renderData
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

public struct DynamicSwiftUIRunner<Inner: View>: View {
    let id: String
    let arg: any Codable
    let content: Inner
    #if DEBUG
    @StateObject private var state: RenderState
    private let server: LocalServer
    #endif
    
    @State private var gradientStart = UnitPoint(x: -1, y: 0.5)
    @State private var gradientEnd = UnitPoint(x: 0, y: 0.5)
    
    public init(
        id: String,
        arg: any Codable,
        @ViewBuilder content: () -> Inner
    ) {
        self.id = id
        self.arg = arg
        // TODO: use id and dynamic register to match the App struct
        self.content = content()
        #if DEBUG
        let server = LocalServer()
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
                    await server.send(interactiveData)
                }
            })
        case .vStack:
            if let children = node.children {
                AnyView(VStack(spacing: CGFloat(Float(node.data["spacing"] ?? "5") ?? 0)) {
                    ForEach(children, id: \.id) { child in
                        buildView(from: child)
                    }
                })
            } else {
                AnyView(EmptyView())
            }
        case .hStack:
            if let children = node.children {
                AnyView(HStack(spacing: CGFloat(Float(node.data["spacing"] ?? "5") ?? 0)) {
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
        
        // 分别应用 frame 和 padding 修饰器
        view
            .modifier(FrameViewModifier(node: node))
            .modifier(PaddingViewModifier(node: node))
            .modifier(ClipShapeViewModifier(node: node))
    }
    
    private struct FrameViewModifier: ViewModifier {
        let node: Node
        
        func body(content: Content) -> some View {
            if let frameData = node.modifier?.frame {
                content.frame(
                    width: frameData.width,
                    height: frameData.height,
                    alignment: parseAlignment(frameData.alignment)
                )
            } else {
                content
            }
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
        let node: Node
        
        func body(content: Content) -> some View {
            if let paddingData = node.modifier?.padding {
                content.padding(parseEdges(paddingData.edges), paddingData.length)
            } else {
                content
            }
        }
        
        private func parseEdges(_ str: String) -> SwiftUI.Edge.Set {
            switch str {
            case "horizontal": return .horizontal
            case "vertical": return .vertical
            case "all": return .all
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
        let node: Node
        
        func body(content: Content) -> some View {
            if let clipShapeData = node.modifier?.clipShape {
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
            } else {
                content
            }
        }
    }
}

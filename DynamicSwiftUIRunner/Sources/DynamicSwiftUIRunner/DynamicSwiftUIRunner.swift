// The Swift Programming Language
// https://docs.swift.org/swift-book
import Combine
import DynamicSwiftUITransferProtocol
import Foundation
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

public struct DynamicSwiftUIRunner: View {
    let id: String
    let content: any View
    #if DEBUG
    @StateObject private var state: RenderState
    private let server: LocalServer
    #endif
    
    public init(id: String, content: any View) {
        self.id = id
        // TODO: use id and dynamic register to match the App struct
        self.content = content
        #if DEBUG
        let server = LocalServer()
        _state = StateObject(wrappedValue: RenderState(id: id, server: server))
        self.server = server
        #endif
    }
    
    public var body: some View {
        VStack {
            Text("Current Renderer is \(state.data?.tree == nil ? "native" : "network")")
            Group {
                if let node = state.data?.tree {
                    buildView(from: node)
                } else {
                    AnyView(self.content)
                }
            }
        }
    }
    
    @ViewBuilder
    private func buildView(from node: Node) -> some View {
        switch node.type {
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
        case .tupleContainer:
            if let children = node.children {
                AnyView(TupleView(children.map { child in
                    buildView(from: child)
                }))
            } else {
                AnyView(EmptyView())
            }
        }
    }
}

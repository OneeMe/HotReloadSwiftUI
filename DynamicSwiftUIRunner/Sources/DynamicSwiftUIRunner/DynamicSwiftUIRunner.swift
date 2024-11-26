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
            .compactMap { jsonString -> RenderData? in
                guard let data = jsonString.data(using: .utf8),
                      let renderData = try? JSONDecoder().decode(RenderData.self, from: data)
                else {
                    print("Failed to decode JSON: \(jsonString)")
                    return nil
                }
                return renderData
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.data, on: self)
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
        Group {
            if let node = state.data?.tree {
                buildView(from: node)
            } else {
                AnyView(self.content.body)
            }
        }
    }
    
    @ViewBuilder
    private func buildView(from node: Node) -> some View {
        switch node.type {
        case .text:
            AnyView(Text(node.data["text"] ?? ""))
        case .button:
            Button(node.data["title"] ?? "") {
                let interactiveData = InteractiveData(id: node.id, type: .tap)
                Task {
                    await server.send(interactiveData)
                }
            }
        case .container:
            if let children = node.children {
                // TODO: Implement container view
                EmptyView()
            }
        }
    }
}

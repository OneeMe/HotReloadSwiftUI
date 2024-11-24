// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation
import Swifter
import SwiftUI
import Combine
import DynamicSwiftUITransferProtocol

class ServerState: ObservableObject {
    @Published var data: JsonData?
    private let server: LocalServer
    private var cancellables = Set<AnyCancellable>()
    
    init(id: String) {
        server = LocalServer()
        
        server.dataPublisher
            .compactMap { jsonString -> JsonData? in
                guard let data = jsonString.data(using: .utf8),
                      let jsonData = try? JSONDecoder().decode(JsonData.self, from: data) else {
                    print("Failed to decode JSON: \(jsonString)")
                    return nil
                }
                return jsonData
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.data, on: self)
            .store(in: &cancellables)
    }
}

public struct DynamicSwiftUIRunner: View {
    let id: String
    @StateObject private var state: ServerState
    
    public init(id: String) {
        self.id = id
        _state = StateObject(wrappedValue: ServerState(id: id))
    }
    
    public var body: some View {
        Group {
            if let node = state.data?.tree {
                buildView(from: node)
            } else {
                EmptyView()
            }
        }
    }
    
    @ViewBuilder
    private func buildView(from node: Node) -> some View {
        switch node.type {
        case .text:
            Text(node.data)
        case .container:
            if let children = node.children {
                VStack {
                    ForEach(Array(children.enumerated()), id: \.offset) { _, child in
                        buildView(from: child)
                    }
                }
            } else {
                EmptyView()
            }
        }
    }
}

private class LocalServer {
    private let server = HttpServer()
    private let dataSubject = PassthroughSubject<String, Never>()
    
    var dataPublisher: AnyPublisher<String, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    init() {
        setupServer()
    }
    
    private func setupServer() {
        server["/ws"] = websocket(
            text: { [weak self] (session, text) in
                print("Received WebSocket message: \(text)")
                self?.dataSubject.send(text)
            },
            binary: { (session, binary) in
                print("Received binary data")
            },
            connected: { session in
                print("WebSocket client connected")
            },
            disconnected: { session in
                print("WebSocket client disconnected")
            }
        )
        
        do {
            try server.start(8080)
            print("WebSocket server started successfully on ws://localhost:8080/ws")
        } catch {
            print("Server start error: \(error)")
        }
    }
    
    deinit {
        server.stop()
    }
}
    

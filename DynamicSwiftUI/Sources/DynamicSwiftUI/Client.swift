//
// DynamicSwiftUI
// Created by: onee on 2024/11/24
//

import Foundation
import DynamicSwiftUITransferProtocol

actor WebSocketClient {
    var isConnected = false
    private var webSocket: URLSessionWebSocketTask?
    private let session = URLSession(configuration: .default)
    
    func setup() {
        guard let url = URL(string: "ws://localhost:8080/ws") else { return }
        webSocket = session.webSocketTask(with: url)
        webSocket?.resume()
        receiveMessage()
        
        print("WebSocket client connecting to server...")
    }
    
    private func receiveMessage() {
        webSocket?.receive { [weak self] result in
            Task { [weak self] in
                await self?.handleReceive(result)
            }
        }
    }
    
    private func handleReceive(_ result: Result<URLSessionWebSocketTask.Message, Error>) {
        switch result {
        case .success(let message):
            switch message {
            case .string(let text):
                print("Received message: \(text)")
            case .data(let data):
                print("Received data: \(data)")
            @unknown default:
                break
            }
            // 继续接收下一条消息
            receiveMessage()
        case .failure(let error):
            print("WebSocket receive error: \(error)")
            // 尝试重新连接
            Task {
                try await Task.sleep(nanoseconds: 1_000_000_000)
                setup()
            }
        }
    }
    
    func send(_ data: JsonData) async {
        if !isConnected {
            setup()
        }
        
        guard let jsonData = try? JSONEncoder().encode(data),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return
        }
        
        let message = URLSessionWebSocketTask.Message.string(jsonString)
        do {
            try await webSocket?.send(message)
        } catch {
            print("WebSocket send error: \(error)")
        }
    }
    
    deinit {
        webSocket?.cancel(with: .goingAway, reason: nil)
    }
}

private let webSocketClient = WebSocketClient()

@MainActor
func runApp<Root: App>(_ app: Root) {
    let viewHierarchy = processScene(app.body)
    let jsonData = JsonData(tree: viewHierarchy)
    
    Task {
        await webSocketClient.send(jsonData)
    }
    
    print("Application started, entering run loop...")
    
    DispatchQueue.main.async {
        let timer = Timer(timeInterval: TimeInterval.infinity, repeats: true) { _ in }
        RunLoop.current.add(timer, forMode: .common)
    }
    
    RunLoop.main.run()
}

private func processScene<S: Scene>(_ scene: S) -> Node {
    print("scene type is \(type(of: scene))")
    if let windowGroup = scene as? WindowGroup {
        return processView(windowGroup.content)
    }
    return Node(type: .container, data: "unknown")
}

private func processView<V: View>(_ view: V) -> Node {
    print("will process view \(type(of: view))")
    if let text = view as? Text {
        return Node(type: .text, data: text.content)
    }
    return processView(view.body)
}

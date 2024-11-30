//
// DynamicSwiftUI
// Created by: onee on 2024/11/24
//

import DynamicSwiftUITransferProtocol
import Foundation

actor WebSocketClient {
    var webSocket: URLSessionWebSocketTask?
    private let session = URLSession(configuration: .default)
    private var continuations: [CheckedContinuation<LaunchData, Error>] = []
    
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
                if let data = text.data(using: .utf8),
                   let transferMessage = try? JSONDecoder().decode(TransferMessage.self, from: data)
                {
                    switch transferMessage {
                    case .interactive(let interactiveData):
                        handleInteraction(interactiveData)
                    case .initialArg(let launchData):
                        receivedLaunchData(launchData)
                    case .render(_), .environmentUpdate:
                        // 客户端不需要处理 renderData/environmentUpdate
                        break
                    }
                }
            case .data(let data):
                print("Received data: \(data)")
            @unknown default:
                break
            }
            receiveMessage()
        case .failure(let error):
            print("WebSocket receive error: \(error)")
            Task {
                try await Task.sleep(nanoseconds: 1_000_000_000)
                setup()
            }
        }
    }
    
    private func handleInteraction(_ data: InteractiveData) {
        switch data.type {
        case .tap:
            // 找到对应的按钮并触发动作
            Task { @MainActor in
                if let button = InteractiveComponentRegistry.shared.getComponent(withId: data.id) {
                    if let button = button as? Button {
                        button.handleTap()
                    }
                }
            }
        }
    }
    
    func send(_ message: TransferMessage) async {
        guard let jsonData = try? JSONEncoder().encode(message),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return
        }
        
        let wsMessage = URLSessionWebSocketTask.Message.string(jsonString)
        do {
            try await webSocket?.send(wsMessage)
        } catch {
            print("WebSocket send error: \(error)")
        }
    }
    
    func waitForLaunchData() async throws -> LaunchData {
        setup()
        print("wait for server's launch data")
        return try await withCheckedThrowingContinuation { continuation in
            continuations.append(continuation)
        }
    }
    
    func receivedLaunchData(_ launchData: LaunchData) {
        if let continuation = continuations.first {
            continuations.removeFirst()
            continuation.resume(returning: launchData)
        }
    }
    
    deinit {
        webSocket?.cancel(with: .goingAway, reason: nil)
    }
}

let webSocketClient = WebSocketClient()

@MainActor func processView<V: View>(_ view: V) -> Node {
    if let convertible = view as? ViewConvertible {
        let node = convertible.convertToNode()
        return node
    }
    return processView(view.body)
}

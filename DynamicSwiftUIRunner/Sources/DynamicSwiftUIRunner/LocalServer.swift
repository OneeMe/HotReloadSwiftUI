//
// DynamicSwiftUIRunner
// Created by: onee on 2024/11/26
//
import Swifter
import Combine
import DynamicSwiftUITransferProtocol
import Foundation

class LocalServer {
    private let server = HttpServer()
    private let dataSubject = PassthroughSubject<String, Never>()
    private var sessions: Set<WebSocketSession> = []
    private let initialArg: any Codable
    
    var dataPublisher: AnyPublisher<String, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    init(initialArg: any Codable) {
        self.initialArg = initialArg
        setupServer()
    }
    
    private func setupServer() {
        server["/ws"] = websocket(
            text: { [weak self] _, text in
                do {
                    guard let data = text.data(using: .utf8) else { return }
                    
                    if let transferMessage = try? JSONDecoder().decode(TransferMessage.self, from: data) {
                        switch transferMessage {
                        case .renderData(let renderData):
                            self?.dataSubject.send(text)
                        case .interactiveData, .initialArg:
                            // 服务端不需要处理这些消息类型
                            break
                        }
                    }
                } catch {
                    print("Failed to parse WebSocket message: \(error)")
                }
            },
            binary: { _, _ in
                print("Received binary data")
            },
            connected: { [weak self] session in
                print("WebSocket client connected")
                self?.sessions.insert(session)
                self?.sendInitialArg(to: session)
            },
            disconnected: { [weak self] session in
                print("WebSocket client disconnected")
                self?.sessions.remove(session)
                self?.dataSubject.send("")
            }
        )
        
        do {
            try server.start(8080)
            print("WebSocket server started successfully on ws://localhost:8080/ws")
        } catch {
            print("Server start error: \(error)")
        }
    }
    
    private func sendInitialArg(to session: WebSocketSession) {
        do {
            print("Preparing to send initial arg")
            let jsonData = try JSONEncoder().encode(initialArg)
            let transferMessage = TransferMessage.initialArg(jsonData)
            if let messageData = try? JSONEncoder().encode(transferMessage),
               let jsonString = String(data: messageData, encoding: .utf8) {
                print("Sending initial arg to client: \(jsonString)")
                session.writeText(jsonString)
            }
        } catch {
            print("Failed to encode initial arg: \(error)")
        }
    }
    
    func sendInteractiveData(_ data: InteractiveData) async {
        let transferMessage = TransferMessage.interactiveData(data)
        guard let jsonData = try? JSONEncoder().encode(transferMessage),
              let jsonString = String(data: jsonData, encoding: .utf8)
        else {
            return
        }
        
        sessions.forEach { session in
            session.writeText(jsonString)
        }
    }
    
    deinit {
        server.stop()
    }
}
    

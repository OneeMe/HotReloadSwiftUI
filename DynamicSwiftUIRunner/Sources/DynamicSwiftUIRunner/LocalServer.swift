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
    private(set) var environment: (any Codable)?
    private let environmentContainer: EnvironmentContainer
    
    var dataPublisher: AnyPublisher<String, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    init(initialArg: any Codable, environment: (any Codable)?) {
        self.initialArg = initialArg
        self.environment = environment
        if let environment = environment,
           let data = try? JSONEncoder().encode(environment) {
            self.environmentContainer = EnvironmentContainer(
                id: String(describing: type(of: environment)),
                data: String(data: data, encoding: .utf8) ?? ""
            )
            print("environment: \(self.environmentContainer.data)")
        } else {
            self.environmentContainer = EnvironmentContainer(
                id: "",
                data: ""
            )
        }
        setupServer()
    }
    
    private func setupServer() {
        server["/ws"] = websocket(
            text: { [weak self] _, text in
                self?.dataSubject.send(text)
            },
            binary: { _, _ in
                print("Received binary data")
            },
            connected: { [weak self] session in
                self?.handleClientConnected(session)
            },
            disconnected: { [weak self] session in
                self?.handleClientDisconnected(session)
            }
        )
        
        startServer()
    }
    
    private func handleClientConnected(_ session: WebSocketSession) {
        print("WebSocket client connected")
        sessions.insert(session)
        sendInitialArg(to: session)
    }
    
    private func handleClientDisconnected(_ session: WebSocketSession) {
        print("WebSocket client disconnected")
        sessions.remove(session)
        dataSubject.send("")
    }
    
    private func startServer() {
        do {
            try server.start(8080)
            print("WebSocket server started successfully on ws://localhost:8080/ws")
        } catch {
            print("Server start error: \(error)")
        }
    }
    
    private func sendInitialArg(to session: WebSocketSession) {
        do {
            let argData = try JSONEncoder().encode(initialArg)
            let launchData = LaunchData(
                arg: String(data: argData, encoding: .utf8) ?? "",
                environment: environmentContainer
            )
            let transferMessage = TransferMessage.initialArg(launchData)
            if let messageData = try? JSONEncoder().encode(transferMessage),
               let jsonString = String(data: messageData, encoding: .utf8) {
                session.writeText(jsonString)
            }
        } catch {
            print("Failed to encode initial arg: \(error)")
        }
    }
    
    func sendInteractiveData(_ data: InteractiveData) async {
        let transferMessage = TransferMessage.interactive(data)
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
    

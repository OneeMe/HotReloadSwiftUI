import Combine
import Foundation
import HotReloadSwiftUITransferProtocol
import Swifter

class InspectorServer: ObservableObject {
    private let server = HttpServer()
    private let port: UInt16

    @Published var databases: [String: Database] = [:]
    @Published var connections: [String: Connection] = [:]
    private var clients: [String: Client] = [:]

    init(port: UInt16 = 44023) {
        self.port = port
        setupServer()
    }

    private func setupServer() {
        server["/ws"] = websocket(
            text: { [weak self] session, text in
                print("received text: \(text)")
                self?.handleWebSocketMessage(session: session, text: text)
            },
            binary: { _, _ in
                print("Received binary data")
            },
            connected: { [weak self] session in
                self?.handleConnected(session)
            },
            disconnected: { [weak self] session in
                self?.handleDisconnected(session)
            }
        )

        startServer()
    }

    private func startServer() {
        do {
            try server.start(port)
            print("WebSocket server started successfully on ws://localhost:\(port)/ws")
        } catch {
            print("Server start error: \(error)")
        }
    }

    private func handleConnected(_: WebSocketSession) {
        print("New WebSocket connected, will receive message to register")
    }

    private func handleDisconnected(_ session: WebSocketSession) {
        print("WebSocket client disconnected")

        // 找到并移除断开连接的客户端
        if let clientId = clients.first(where: { $0.value.session === session })?.key {
            clients.removeValue(forKey: clientId)

            // 更新连接状态
            if let connectionId = connections.first(where: { $0.value.client.session === session })?.key {
                connections[connectionId]?.status = .disconnected
            }
        }

        // 找到并移除断开连接的数据库
        if let databasePackage = databases.first(where: { $0.value.session === session })?.key {
            databases.removeValue(forKey: databasePackage)

            // 移除相关的连接
            connections = connections.filter { $0.value.database.databaseId.package != databasePackage }
        }
    }

    private func handleWebSocketMessage(session: WebSocketSession, text: String) {
        guard let data = text.data(using: .utf8),
              let message = try? JSONDecoder().decode(TransferMessage.self, from: data)
        else {
            print("Failed to decode message")
            return
        }

        switch message {
        case let .register(info):
            handleRegister(session: session, info: info)
        case let .execute(info):
            switch info {
            case let .initialArg(launchData):
                handleInitialArg(session: session, launchData: launchData)
            case let .interactive(data):
                handleInteractive(session: session, data: data)
            default:
                break
            }
        case .disconnected:
            handleDisconnected(session)
        }
    }

    private func handleRegister(session: WebSocketSession, info: RegisterTransferMessage) {
        switch info.role {
        case let .database(id):
            let database = Database(id: id, session: session)
            databases[id.package] = database

        case let .client(id):
            let client = Client(id: id, name: info.deviceInfo ?? "Unknown Device", session: session)
            clients[id.package] = client

            // 如果存在对应的数据库，创建连接
            if let database = databases[id.package] {
                let connection = Connection(
                    database: database,
                    client: client,
                    status: .connected
                )
                let connectionId = "\(id.package)_\(id.unit)"
                connections[connectionId] = connection
            }
        }
    }

    private func handleInitialArg(session: WebSocketSession, launchData: LaunchData) {
        // 找到对应的连接并转发
        if let connection = connections.first(where: { $0.value.client.session === session })?.value {
            if let messageData = try? JSONEncoder().encode(TransferMessage.execute(.initialArg(launchData))),
               let jsonString = String(data: messageData, encoding: .utf8)
            {
                connection.database.session.writeText(jsonString)
            }
        }
    }

    private func handleInteractive(session: WebSocketSession, data: InteractiveData) {
        // 找到对应的连接并转发
        if let connection = connections.first(where: { $0.value.client.session === session })?.value {
            if let messageData = try? JSONEncoder().encode(TransferMessage.execute(.interactive(data))),
               let jsonString = String(data: messageData, encoding: .utf8)
            {
                connection.database.session.writeText(jsonString)
            }
        }
    }

    deinit {
        server.stop()
    }
}

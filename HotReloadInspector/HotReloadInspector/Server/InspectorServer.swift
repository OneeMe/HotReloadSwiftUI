import Combine
import Foundation
import HotReloadSwiftUITransferProtocol
import Swifter

class InspectorServer: ObservableObject {
    private let server = HttpServer()
    private let port: UInt16

    /// key 是 <package>
    @Published var databases: [String: Database] = [:]
    /// key 是 <client_id>_<database_id>
    @Published var connections: [String: Connection] = [:]
    /// key 是 <client.id>
    private var clients: [Client] = []

    init(port: UInt16 = 44023) {
        self.port = port
        setupServer()
    }

    private func setupServer() {
        server["/ws"] = websocket(
            text: { [weak self] session, text in
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

        Task { @MainActor in
            // 找到并移除断开连接的客户端
            for (index, client) in clients.enumerated() {
                if client.session === session {
                    // 先将所有相关连接标记为断开
                    for connection in connections.values where connection.client.session === session {
                        connection.status = .disconnected
                    }
                    // 然后移除客户端
                    clients.remove(at: index)
                    break
                }
            }

            // 找到并移除断开连接的数据库
            if let databasePackage = databases.first(where: { $0.value.session === session })?.key {
                // 先将所有相关连接标记为断开
                for connection in connections.values where connection.database.session === session {
                    connection.status = .disconnected
                }
                // 然后移除数据库
                databases.removeValue(forKey: databasePackage)
                // 最后清理断开的连接
                connections = connections.filter { $0.value.status == .connected }
            }
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
        case .execute:
            forwardMessage(from: session, message: message)
        case .disconnected:
            handleDisconnected(session)
        }
    }

    private func handleRegister(session: WebSocketSession, info: RegisterTransferMessage) {
        switch info.role {
        case let .database(id):
            print("handle register from database: \(id)")
            Task { @MainActor in
                let database = Database(databaseId: id, session: session)
                databases[id.package] = database

                print("try to connect with existing clients")

                // 查找所有匹配的客户端，重新建立连接
                let expectedClientKeys = database.databaseId.units.map { "\(id.package)/\($0)" }
                let matchingClients = clients.filter { expectedClientKeys.contains($0.shortId) }
                print("found \(matchingClients.count) matching clients")
                if let lastClient = matchingClients.last {
                    for client in matchingClients {
                        print("creating connection for client: \(client.clientId)")
                        // 创建新的连接
                        let connection = Connection(
                            database: database,
                            client: client,
                            status: .connected
                        )
                        connections[connection.id] = connection
                    }

                    // TODO: 这里采取最粗暴的策略，只回放最后一个
                    // 如果有启动参数，发送给新连接的数据库
                    if let launchData = lastClient.lastLaunchData {
                        print("replay launch data")
                        forwardMessage(from: lastClient.session, message: .execute(.initialArg(launchData)), isRecord: false)
                    }

                    // 重放所有交互历史
                    print("replay \(lastClient.interactiveHistory.count) interactive messages")
                    for interactiveData in lastClient.interactiveHistory {
                        forwardMessage(from: lastClient.session, message: .execute(.interactive(interactiveData)), isRecord: false)
                    }
                }
            }

        case let .client(id):
            print("handle register from client: \(id)")
            let client = Client(clientId: id, name: info.deviceInfo ?? "Unknown Device", session: session)
            let clientKey = id.description

            Task { @MainActor in
                // 添加客户端
                clients.append(client)
                print("add client to clients: \(clientKey)")

                // 如果存在对应的数据库，创建连接
                if let database = databases[id.package], let connection = establishConnection(database: database, client: client) {
                    print("establish connection with database: \(database.databaseId)")
                    // 如果数据库有最新的渲染数据，发送给新连接的客户端
                    if let renderData = connection.database.lastRenderData {
                        print("forward render data to client: \(connection.client.clientId)")
                        forwardMessage(from: connection.database.session, message: .execute(.render(renderData)), isRecord: false)
                    }
                    if let environmentUpdate = connection.database.lastEnvironmentUpdate {
                        print("forward environment update to client: \(connection.client.clientId)")
                        forwardMessage(from: database.session, message: .execute(.environmentUpdate(environmentUpdate)), isRecord: false)
                    }
                }
            }
        }
    }

    private func establishConnection(database: Database, client: Client) -> Connection? {
        if database.databaseId.package == client.clientId.package, database.databaseId.units.contains(client.clientId.unit) {
            let connection = Connection(
                database: database,
                client: client,
                status: .connected
            )
            connections[connection.id] = connection
            return connection
        }
        return nil
    }

    private func forwardMessage(from session: WebSocketSession, message: TransferMessage, isRecord: Bool = true) {
        // 找到所有相关的连接
        let matchedConnections: [Connection]
        if let connection = connections.first(where: { $0.value.client.session === session })?.value {
            // 如果是客户端发来的消息，转发给对应的数据库
            if connection.status == .connected {
                matchedConnections = [connection]

                let client = connection.client
                // 存储客户端的消息
                if case let .execute(executeMessage) = message, isRecord {
                    switch executeMessage {
                    case let .initialArg(launchData):
                        client.lastLaunchData = launchData
                    case let .interactive(data):
                        client.interactiveHistory.append(data)
                    default:
                        break
                    }
                }
            } else {
                print("Skip forwarding message from disconnected client")
                matchedConnections = []
            }
        } else if let database = databases.first(where: { $0.value.session === session })?.value {
            // 如果是数据库发来的消息，转发给所有连接到这个数据库的客户端
            matchedConnections = connections.values.filter {
                $0.database.session === session && $0.status == .connected
            }
            if matchedConnections.isEmpty {
                print("No connected clients found for database")
            }
            // 存储数据库的消息
            if case let .execute(executeMessage) = message, isRecord {
                switch executeMessage {
                case let .render(renderData):
                    database.lastRenderData = renderData
                case let .environmentUpdate(container):
                    database.lastEnvironmentUpdate = container
                default:
                    break
                }
            }
        } else {
            print("No matching connection found for session")
            return
        }

        // 编码并发送消息
        if let messageData = try? JSONEncoder().encode(message),
           let jsonString = String(data: messageData, encoding: .utf8)
        {
            for connection in matchedConnections {
                guard connection.status == .connected else {
                    print("Skip sending to disconnected connection")
                    continue
                }

                // 根据消息类型决定发送方向
                switch message {
                case let .execute(executeMessage):
                    switch executeMessage {
                    case .initialArg, .interactive:
                        // 客户端发来的消息，转发给数据库
                        print("forward message to database: \(connection.database.databaseId)")
                        connection.database.session.writeText(jsonString)
                    case .render, .environmentUpdate:
                        // 数据库发来的消息，转发给客户端
                        print("forward message to client: \(connection.client.clientId)")
                        connection.client.session.writeText(jsonString)
                    }
                default:
                    break
                }
            }
        }
    }

    deinit {
        server.stop()
    }
}

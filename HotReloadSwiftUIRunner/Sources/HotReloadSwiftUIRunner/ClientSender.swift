import Combine
import Foundation
import HotReloadSwiftUITransferProtocol

class ClientSender {
    private var webSocket: URLSessionWebSocketTask?
    private let session = URLSession(configuration: .default)
    private let messageSubject = PassthroughSubject<ExecuteTransferMessage, Never>()
    private let id: ClientUnitId
    private let name: String
    private var cancellables = Set<AnyCancellable>()

    var messagePublisher: AnyPublisher<ExecuteTransferMessage, Never> {
        messageSubject.eraseToAnyPublisher()
    }

    init(id: ClientUnitId, name: String) {
        self.id = id
        self.name = name
    }

    func connect() async throws {
        guard let url = URL(string: "ws://localhost:44023/ws") else {
            throw NSError(domain: "ClientSender", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }

        webSocket = session.webSocketTask(with: url)
        webSocket?.resume()

        // 发送注册消息
        let registerMessage = RegisterTransferMessage(
            role: .client(id: id),
            deviceInfo: name
        )
        try await send(.register(registerMessage))

        // 开始接收消息
        receiveMessage()
    }

    func disconnect() async {
        webSocket?.cancel(with: .goingAway, reason: nil)
        webSocket = nil
    }

    func sendInitialArg(_ launchData: LaunchData) async throws {
        try await send(.execute(.initialArg(launchData)))
    }

    func sendInteractiveData(_ data: InteractiveData) async throws {
        try await send(.execute(.interactive(data)))
    }

    private func send(_ message: TransferMessage) async throws {
        let data = try JSONEncoder().encode(message)
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "ClientSender", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode message"])
        }
        let wsMessage = URLSessionWebSocketTask.Message.string(jsonString)
        try await webSocket?.send(wsMessage)
    }

    private func receiveMessage() {
        webSocket?.receive { [weak self] result in
            Task { [weak self] in
                switch result {
                case let .success(message):
                    switch message {
                    case let .string(text):
                        await self?.handleTextMessage(text)
                    case let .data(data):
                        break
                    @unknown default:
                        break
                    }
                    // 继续接收下一条消息
                    self?.receiveMessage()
                case let .failure(error):
                    print("WebSocket receive error: \(error)")
                    // 尝试重新连接
                    try? await self?.connect()
                }
            }
        }
    }

    private func handleTextMessage(_ text: String) {
        guard let data = text.data(using: .utf8),
              let message = try? JSONDecoder().decode(TransferMessage.self, from: data)
        else {
            print("Failed to decode message: \(text)")
            return
        }
        self.handleMessage(message)
    }

    private func handleMessage(_ message: TransferMessage) {
        switch message {
        case let .register(info):
            print("收到注册响应: \(info)")
        case let .execute(info):
            print("收到执行响应: \(info)")
            switch info {
            case let .render(renderData):
                messageSubject.send(.render(renderData))
            case let .environmentUpdate(container):
                messageSubject.send(.environmentUpdate(container))
            case let .interactive(interactiveData):
                break
            default:
                break
            }
        case let .disconnected(info):
            print("收到断开连接消息: \(info)")
            Task {
                await disconnect()
            }
        }
    }
}

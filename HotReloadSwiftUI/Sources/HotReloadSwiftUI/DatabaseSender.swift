//
// HotReloadSwiftUI
// Created by: onee on 2024/11/24
//

import Combine
import Foundation
import HotReloadSwiftUITransferProtocol

public enum ClientConfig {
    public nonisolated(unsafe) static var address: String = "localhost"
}

actor DatabaseSender {
    private var webSocket: URLSessionWebSocketTask?
    private let session = URLSession(configuration: .default)
    private var continuations: [CheckedContinuation<LaunchData, Error>] = []

    let id: DatabaseUnitId

    init(id: DatabaseUnitId) {
        self.id = id
    }

    func setup() async throws {
        guard let url = URL(string: "ws://\(ClientConfig.address):44023/ws") else {
            throw NSError(domain: "DatabaseSender", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }

        webSocket = session.webSocketTask(with: url)
        webSocket?.resume()

        let role = Role.database(id: id)

        // 发送注册消息
        let registerMessage = RegisterTransferMessage(
            role: role,
            deviceInfo: getDeviceModel() ?? "Unknown Device"
        )
        print("send register message")
        try await send(.register(registerMessage))

        // 开始接收消息
        receiveMessage()
    }

    private func receiveMessage() {
        webSocket?.receive { [weak self] result in
            Task { [weak self] in
                switch result {
                case let .success(message):
                    switch message {
                    case let .string(text):
                        await self?.handleMessage(text)
                    case let .data(data):
                        break
                    @unknown default:
                        break
                    }
                case let .failure(error):
                    print("WebSocket receive error: \(error)")
                    // 5s 后尝试重新连接
                    try? await Task.sleep(nanoseconds: 5_000_000_000)
                    try? await self?.setup()
                }
            }
        }
    }

    private func handleMessage(_ text: String) {
        guard let data = text.data(using: .utf8),
              let message = try? JSONDecoder().decode(TransferMessage.self, from: data)
        else {
            return
        }
        switch message {
        case .register:
            print("收到注册响应")
        case let .execute(executeMessage):
            switch executeMessage {
            case let .interactive(interactiveData):
                handleInteraction(interactiveData)
            case let .initialArg(launchData):
                receivedLaunchData(launchData)
            case .render(_), .environmentUpdate:
                // 数据库不需要处理 renderData/environmentUpdate
                break
            }
        case .disconnected:
            Task {
                await disconnect()
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
        do {
            let data = try JSONEncoder().encode(message)
            guard let jsonString = String(data: data, encoding: .utf8) else {
                throw NSError(domain: "DatabaseSender", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode message"])
            }
            let wsMessage = URLSessionWebSocketTask.Message.string(jsonString)
            try await webSocket?.send(wsMessage)
        } catch {
            print("Failed to send message: \(error)")
        }
    }

    func waitForLaunchData() async throws -> LaunchData {
        try await setup()
        print("wait for client's launch data")
        return try await withCheckedThrowingContinuation { continuation in
            continuations.append(continuation)
        }
    }

    private func receivedLaunchData(_ launchData: LaunchData) {
        if let continuation = continuations.first {
            continuations.removeFirst()
            continuation.resume(returning: launchData)
        }
    }

    private func disconnect() async {
        webSocket?.cancel(with: .goingAway, reason: nil)
        webSocket = nil
    }

    deinit {
        // TODO: disconnect
    }
}

let database = DatabaseSender(
    id: DatabaseUnitId(package: "spatial.onee.Foo", units: ["Foo"])
)

@MainActor func processView<V: View>(_ view: V) -> Node {
    if let convertible = view as? ViewConvertible {
        let node = convertible.convertToNode()
        return node
    }
    return processView(view.body)
}

func getDeviceModel() -> String {
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let identifier = machineMirror.children.compactMap { element -> String? in
        guard let value = element.value as? Int8, value != 0 else { return nil }
        return String(UnicodeScalar(UInt8(value)))
    }.joined()

    return identifier
}

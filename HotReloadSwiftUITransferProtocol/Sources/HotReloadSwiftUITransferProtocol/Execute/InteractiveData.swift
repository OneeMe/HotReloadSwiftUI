//
// HotReloadSwiftUITransferProtocol
// Created by: onee on 2025/1/6
//

public struct InteractiveData: Codable, Sendable {
    public enum InteractiveType: String, Codable, Sendable {
        case tap
    }

    public let id: String
    public let type: InteractiveType

    public init(id: String, type: InteractiveType) {
        self.id = id
        self.type = type
    }
}

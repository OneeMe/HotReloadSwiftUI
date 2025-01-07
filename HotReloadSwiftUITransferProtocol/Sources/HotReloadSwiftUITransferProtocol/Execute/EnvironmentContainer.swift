//
// HotReloadSwiftUITransferProtocol
// Created by: onee on 2025/1/6
//

public struct EnvironmentContainer: Codable, Sendable {
    public let id: String
    public let data: String

    public init(id: String, data: String) {
        self.id = id
        self.data = data
    }
}

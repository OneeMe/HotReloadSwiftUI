import Foundation

public enum TransferMessage: Codable {
    case register(RegisterTransferMessage)
    case execute(ExecuteTransferMessage)
    case disconnected(DisconnectedTransferMessage)

    private enum CodingKeys: String, CodingKey {
        case type
        case data
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "register":
            let data = try container.decode(RegisterTransferMessage.self, forKey: .data)
            self = .register(data)
        case "execute":
            let data = try container.decode(ExecuteTransferMessage.self, forKey: .data)
            self = .execute(data)
        case "disconnected":
            let data = try container.decode(DisconnectedTransferMessage.self, forKey: .data)
            self = .disconnected(data)
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Invalid type value: \(type)"
                )
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .register(info):
            try container.encode("register", forKey: .type)
            try container.encode(info, forKey: .data)
        case let .execute(info):
            try container.encode("execute", forKey: .type)
            try container.encode(info, forKey: .data)
        case let .disconnected(info):
            try container.encode("disconnected", forKey: .type)
            try container.encode(info, forKey: .data)
        }
    }
}

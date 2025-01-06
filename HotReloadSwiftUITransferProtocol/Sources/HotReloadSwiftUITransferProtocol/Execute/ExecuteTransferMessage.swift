/// HotReloadSwiftUITransferProtocol
/// Created by: onee on 2024/11/24
///
import Foundation

public enum ExecuteTransferMessage: Codable, Sendable {
    case initialArg(LaunchData) // 初始化参数
    case render(RenderData) // 渲染数据
    case interactive(InteractiveData) // 交互数据
    case environmentUpdate(EnvironmentContainer) // 新增环境值更新消息类型

    private enum CodingKeys: String, CodingKey {
        case type
        case payload
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "initialArg":
            let data = try container.decode(LaunchData.self, forKey: .payload)
            self = .initialArg(data)
        case "render":
            let renderData = try container.decode(RenderData.self, forKey: .payload)
            self = .render(renderData)
        case "interactive":
            let interactiveData = try container.decode(InteractiveData.self, forKey: .payload)
            self = .interactive(interactiveData)
        case "environmentUpdate":
            let data = try container.decode(EnvironmentContainer.self, forKey: .payload)
            self = .environmentUpdate(data)
        default:
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Unknown message type"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .initialArg(data):
            try container.encode("initialArg", forKey: .type)
            try container.encode(data, forKey: .payload)
        case let .render(renderData):
            try container.encode("render", forKey: .type)
            try container.encode(renderData, forKey: .payload)
        case let .interactive(interactiveData):
            try container.encode("interactive", forKey: .type)
            try container.encode(interactiveData, forKey: .payload)
        case let .environmentUpdate(data):
            try container.encode("environmentUpdate", forKey: .type)
            try container.encode(data, forKey: .payload)
        }
    }
}

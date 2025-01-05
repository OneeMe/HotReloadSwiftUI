/// HotReloadSwiftUITransferProtocol
/// Created by: onee on 2024/11/24
///
import Foundation

public struct RenderData: Codable, Sendable {
    public let tree: Node

    public init(tree: Node) {
        self.tree = tree
    }
}

public struct Node: Codable, Sendable {
    public enum NodeType: String, Codable, Sendable {
        case text
        case vStack
        case hStack
        case button
        case tupleContainer
        case divider
        case spacer
        case image
        case binding
    }

    public struct Modifier: Codable, Sendable {
        public enum ModifierType: String, Codable, Sendable {
            case frame
            case padding
            case clipShape
            case labelStyle
            case foregroundStyle
            case font
        }

        public enum ModifierData: Codable, Sendable {
            case frame(FrameData)
            case padding(PaddingData)
            case clipShape(ClipShapeData)
            case labelStyle(LabelStyleData)
            case foregroundStyle(ForegroundStyleData)
            case font(FontData)
            private enum CodingKeys: String, CodingKey {
                case type, data
            }

            public func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                switch self {
                case let .frame(data):
                    try container.encode("frame", forKey: .type)
                    try container.encode(data, forKey: .data)
                case let .padding(data):
                    try container.encode("padding", forKey: .type)
                    try container.encode(data, forKey: .data)
                case let .clipShape(data):
                    try container.encode("clipShape", forKey: .type)
                    try container.encode(data, forKey: .data)
                case let .labelStyle(data):
                    try container.encode("labelStyle", forKey: .type)
                    try container.encode(data, forKey: .data)
                case let .foregroundStyle(data):
                    try container.encode("foregroundStyle", forKey: .type)
                    try container.encode(data, forKey: .data)
                case let .font(data):
                    try container.encode("font", forKey: .type)
                    try container.encode(data, forKey: .data)
                }
            }

            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                let type = try container.decode(String.self, forKey: .type)
                switch type {
                case "frame":
                    let data = try container.decode(FrameData.self, forKey: .data)
                    self = .frame(data)
                case "padding":
                    let data = try container.decode(PaddingData.self, forKey: .data)
                    self = .padding(data)
                case "clipShape":
                    let data = try container.decode(ClipShapeData.self, forKey: .data)
                    self = .clipShape(data)
                case "labelStyle":
                    let data = try container.decode(LabelStyleData.self, forKey: .data)
                    self = .labelStyle(data)
                case "foregroundStyle":
                    let data = try container.decode(ForegroundStyleData.self, forKey: .data)
                    self = .foregroundStyle(data)
                case "font":
                    let data = try container.decode(FontData.self, forKey: .data)
                    self = .font(data)
                default:
                    throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Unknown modifier type"))
                }
            }
        }

        public let type: ModifierType
        public let data: ModifierData

        public init(type: ModifierType, data: ModifierData) {
            self.type = type
            self.data = data
        }
    }

    public struct FrameData: Codable, Sendable {
        public let width: CGFloat?
        public let height: CGFloat?
        public let alignment: String?

        public init(
            width: CGFloat? = nil,
            height: CGFloat? = nil,
            alignment: String? = nil
        ) {
            self.width = width
            self.height = height
            self.alignment = alignment
        }
    }

    public struct PaddingData: Codable, Sendable {
        public let edges: String
        public let length: CGFloat?

        public init(
            edges: String,
            length: CGFloat? = nil
        ) {
            self.edges = edges
            self.length = length
        }
    }

    public struct ClipShapeData: Codable, Sendable {
        public let shapeType: String

        public init(shapeType: String) {
            self.shapeType = shapeType
        }
    }

    public struct LabelStyleData: Codable, Sendable {
        public let style: String

        public init(style: String) {
            self.style = style
        }
    }

    public struct ForegroundStyleData: Codable, Sendable {
        public let color: String

        public init(color: String) {
            self.color = color
        }
    }

    public let id: String
    public let type: NodeType
    public let data: [String: String]
    public let children: [Node]?
    public var modifiers: [Modifier]?

    public init(
        id: String,
        type: NodeType,
        data: [String: String],
        children: [Node]? = nil,
        modifiers: [Modifier]? = nil
    ) {
        self.id = id
        self.type = type
        self.data = data
        self.children = children
        self.modifiers = modifiers
    }

    public struct FontData: Codable, Sendable {
        public let style: String

        public init(style: String) {
            self.style = style
        }
    }
}

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

public enum TransferMessage: Codable, Sendable {
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

public struct LaunchData: Codable, Sendable {
    public let arg: String
    public let environment: EnvironmentContainer

    public init(arg: String, environment: EnvironmentContainer) {
        self.arg = arg
        self.environment = environment
    }
}

public struct EnvironmentContainer: Codable, Sendable {
    public let id: String
    public let data: String

    public init(id: String, data: String) {
        self.id = id
        self.data = data
    }
}

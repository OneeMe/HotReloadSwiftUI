/// DynamicSwiftUITransferProtocol
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
    }
    
    public struct Modifier: Codable, Sendable {
        public var frame: FrameData?
        public var padding: PaddingData?
        
        public init(
            frame: FrameData? = nil,
            padding: PaddingData? = nil
        ) {
            self.frame = frame
            self.padding = padding
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
    
    public let id: String
    public let type: NodeType
    public let data: [String: String]
    public let children: [Node]?
    public let modifier: Modifier?
    
    public init(
        id: String,
        type: NodeType,
        data: [String: String],
        children: [Node]? = nil,
        modifier: Modifier? = nil
    ) {
        self.id = id
        self.type = type
        self.data = data
        self.children = children
        self.modifier = modifier
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
    

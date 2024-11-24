// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public struct JsonData: Codable {
    public let tree: Node
    
    public init(tree: Node) {
        self.tree = tree
    }
}

public struct Node: Codable {
    public enum NodeType: String, Codable {
        case text
        case container
    }
    
    public let type: NodeType
    public let data: String
    public let children: [Node]?
    
    public init(type: NodeType, data: String, children: [Node]? = nil) {
        self.type = type
        self.data = data
        self.children = children
    }
}

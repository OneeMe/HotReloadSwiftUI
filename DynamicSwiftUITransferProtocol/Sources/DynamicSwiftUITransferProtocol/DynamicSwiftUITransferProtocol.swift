// The Swift Programming Language
// https://docs.swift.org/swift-book

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
        case container
        case button
    }
    
    public let id: String
    public let type: NodeType
    public let data: [String: String]
    public let children: [Node]?
    
    public init(id: String, type: NodeType, data: [String: String], children: [Node]? = nil) {
        self.id = id
        self.type = type
        self.data = data
        self.children = children
    }
}

public struct InteractiveData: Codable, Sendable {
    public enum InteractiveType: String, Codable, Sendable {
        case tap
    }
    
    public let id: String
    public let type: InteractiveType
}
    

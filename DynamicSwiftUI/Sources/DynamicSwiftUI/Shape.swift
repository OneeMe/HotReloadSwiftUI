//
// DynamicSwiftUI
// Created by: onee on 2024/11/28
//

import Foundation

@MainActor
public protocol Shape {
    var type: ShapeType { get }
}

public enum ShapeType: String, Codable {
    case circle
    case rectangle
    case capsule
}

@MainActor
public struct Circle: Shape {
    public let type: ShapeType = .circle
    
    public init() {}
}

@MainActor
public struct Rectangle: Shape {
    public let type: ShapeType = .rectangle
    
    public init() {}
}

@MainActor
public struct Capsule: Shape {
    public let type: ShapeType = .capsule
    
    public init() {}
}

public struct FillStyle {
    public init() {}
} 

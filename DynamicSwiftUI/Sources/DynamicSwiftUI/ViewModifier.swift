//
// DynamicSwiftUI
// Created by: onee on 2024/11/28
//

import Foundation

@MainActor
public protocol ViewModifier {
}

@MainActor
public struct FrameModifier: ViewModifier {
    let width: CGFloat?
    let height: CGFloat?
    let alignment: Alignment?
    
    public init(width: CGFloat? = nil, height: CGFloat? = nil, alignment: Alignment? = nil) {
        self.width = width
        self.height = height
        self.alignment = alignment
    }
}

public enum Alignment: String {
    case topLeading, top, topTrailing
    case leading, center, trailing
    case bottomLeading, bottom, bottomTrailing
}

public enum Edge: String, Codable, Sendable {
    case top, leading, bottom, trailing
    
    public struct Set: Codable, Sendable {
        let rawValue: [Edge]
        
        public static let all = Set(rawValue: [.top, .leading, .bottom, .trailing])
        public static let horizontal = Set(rawValue: [.leading, .trailing])
        public static let vertical = Set(rawValue: [.top, .bottom])
        
        public static let top = Set(rawValue: [.top])
        public static let leading = Set(rawValue: [.leading])
        public static let bottom = Set(rawValue: [.bottom])
        public static let trailing = Set(rawValue: [.trailing])
        
        public init(rawValue: [Edge]) {
            self.rawValue = rawValue
        }
        
        var description: String {
            if rawValue == Set.all.rawValue { return "all" }
            if rawValue == Set.horizontal.rawValue { return "horizontal" }
            if rawValue == Set.vertical.rawValue { return "vertical" }
            if rawValue.count == 1, let edge = rawValue.first {
                return edge.rawValue
            }
            return rawValue.map { $0.rawValue }.joined(separator: ",")
        }
    }
}

@MainActor
public struct PaddingModifier: ViewModifier {
    let edges: Edge.Set
    let length: CGFloat?
    
    public init(edges: Edge.Set = .all, length: CGFloat? = nil) {
        self.edges = edges
        self.length = length
    }
}

@MainActor
public struct ClipShapeModifier<S: Shape>: ViewModifier {
    let shape: S
    let style: FillStyle
    
    public init(shape: S, style: FillStyle = FillStyle()) {
        self.shape = shape
        self.style = style
    }
}

@MainActor
public struct LabelStyleModifier: ViewModifier {
    let style: LabelStyle
    
    public init(_ style: LabelStyle) {
        self.style = style
    }
}

@MainActor
public struct ForegroundStyleModifier: ViewModifier {
    let style: any ShapeStyle
    
    public init(_ style: any ShapeStyle) {
        self.style = style
    }
}

@MainActor
public struct FontModifier: ViewModifier {
    let font: Font
    
    public init(_ font: Font) {
        self.font = font
    }
}

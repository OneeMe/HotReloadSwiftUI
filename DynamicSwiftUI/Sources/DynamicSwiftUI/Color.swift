//
// DynamicSwiftUI
// Created by: onee on 2024/11/28
//

import Foundation

public protocol ShapeStyle {
    var rawValue: String { get }
}

public struct Color: ShapeStyle, Codable {
    public let rawValue: String
    
    nonisolated(unsafe) public static let yellow = Color(rawValue: "yellow")
    nonisolated(unsafe) public static let gray = Color(rawValue: "gray")
    nonisolated(unsafe) public static let primary = Color(rawValue: "primary")
    nonisolated(unsafe) public static let secondary = Color(rawValue: "secondary")
    nonisolated(unsafe) public static let accentColor = Color(rawValue: "tint")
}

public extension View {
    @inlinable
    @MainActor
    func foregroundStyle<S: ShapeStyle>(_ style: S) -> ModifiedContent<Self, ForegroundStyleModifier> {
        ModifiedContent(content: self, modifier: ForegroundStyleModifier(style))
    }
}

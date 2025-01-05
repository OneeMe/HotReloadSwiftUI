//
// HotReloadSwiftUI
// Created by: onee on 2024/11/28
//

import Foundation

public protocol ShapeStyle {
    var rawValue: String { get }
}

public struct Color: ShapeStyle, Codable {
    public let rawValue: String

    public nonisolated(unsafe) static let yellow = Color(rawValue: "yellow")
    public nonisolated(unsafe) static let gray = Color(rawValue: "gray")
    public nonisolated(unsafe) static let primary = Color(rawValue: "primary")
    public nonisolated(unsafe) static let secondary = Color(rawValue: "secondary")
    public nonisolated(unsafe) static let accentColor = Color(rawValue: "tint")
}

public extension View {
    @inlinable
    @MainActor
    func foregroundStyle<S: ShapeStyle>(_ style: S) -> ModifiedContent<Self, ForegroundStyleModifier> {
        ModifiedContent(content: self, modifier: ForegroundStyleModifier(style))
    }
}

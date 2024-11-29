//
// DynamicSwiftUI
// Created by: onee on 2024/11/28
//

import Foundation

public struct Color {
    let rawValue: String
    
    nonisolated(unsafe) public static let yellow = Color(rawValue: "yellow")
    nonisolated(unsafe)public static let gray = Color(rawValue: "gray")
    nonisolated(unsafe)public static let primary = Color(rawValue: "primary")
    nonisolated(unsafe)public static let secondary = Color(rawValue: "secondary")
    nonisolated(unsafe)public static let accentColor = Color(rawValue: "tint")
}

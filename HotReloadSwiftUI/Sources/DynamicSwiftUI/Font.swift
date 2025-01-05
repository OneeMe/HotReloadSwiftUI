//
// HotReloadSwiftUI
// Created by: onee on 2024/11/28
//

import Foundation

public struct Font: Codable, Sendable {
    let style: Style

    public static let title = Font(style: .title)
    public static let title2 = Font(style: .title2)
    public static let subheadline = Font(style: .subheadline)

    public enum Style: String, Codable, Sendable {
        case largeTitle
        case title
        case title2
        case title3
        case headline
        case subheadline
        case body
        case callout
        case footnote
        case caption
        case caption2
    }
}

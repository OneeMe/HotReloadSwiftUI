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

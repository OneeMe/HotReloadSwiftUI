//
// DynamicSwiftUI
// Created by: onee on 2024/11/24
//

import DynamicSwiftUITransferProtocol

@MainActor
public protocol View {
    associatedtype Body: View
    var body: Self.Body { get }
}

@resultBuilder
public enum ViewBuilder {
    public static func buildBlock<Content: View>(_ content: Content) -> Content {
        content
    }
}

protocol ViewConvertible {
    func convertToNode() -> Node
}

//
// HotReloadSwiftUITransferProtocol
// Created by: onee on 2025/1/6
//


public struct RenderData: Codable, Sendable {
    public let tree: Node

    public init(tree: Node) {
        self.tree = tree
    }
}
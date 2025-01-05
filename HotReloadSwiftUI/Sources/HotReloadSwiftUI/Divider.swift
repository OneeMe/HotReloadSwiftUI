//
// HotReloadSwiftUI
// Created by: onee on 2024/11/28
//

import Foundation
import HotReloadSwiftUITransferProtocol

@MainActor
public struct Divider: View {
    let id: String = UUID().uuidString

    public init() {}

    public var body: some View {
        self
    }
}

extension Divider: ViewConvertible {
    func convertToNode() -> Node {
        return Node(id: id, type: .divider, data: [:])
    }
}

//
// HotReloadSwiftUI
// Created by: onee on 2024/11/24
//

import Foundation
import HotReloadSwiftUITransferProtocol

@MainActor
public struct Text: View {
    let id: String = UUID().uuidString
    let content: String

    public init(_ content: String) {
        self.content = content
    }

    public var body: Self { self }
}

extension Text: ViewConvertible {
    func convertToNode() -> Node {
        return Node(id: id, type: .text, data: ["text": content])
    }
}

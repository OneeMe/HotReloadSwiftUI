//
// HotReloadSwiftUI
// Created by: onee on 2024/11/28
//

import Foundation
import HotReloadSwiftUITransferProtocol

@MainActor
public struct Spacer: View {
    let id: String = UUID().uuidString
    let minLength: CGFloat?

    public init(minLength: CGFloat? = nil) {
        self.minLength = minLength
    }

    public var body: some View {
        self
    }
}

extension Spacer: ViewConvertible {
    func convertToNode() -> Node {
        var data: [String: String] = [:]
        if let minLength = minLength {
            data["minLength"] = "\(minLength)"
        }
        return Node(id: id, type: .spacer, data: data)
    }
}

//
// HotReloadSwiftUI
// Created by: onee on 2024/11/24
//

import Foundation
import HotReloadSwiftUITransferProtocol

@MainActor
public struct AnyView: View {
    private let _makeView: () -> any View

    public init<V: View>(_ view: V) {
        _makeView = { view }
    }

    public var body: some View {
        self
    }
}

extension AnyView: ViewConvertible {
    func convertToNode() -> Node {
        let view = _makeView()
        return processView(view)
    }
}

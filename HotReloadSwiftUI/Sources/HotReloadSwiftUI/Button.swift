//
// HotReloadSwiftUI
// Created by: onee on 2024/11/24
//

import Foundation
import HotReloadSwiftUITransferProtocol

@MainActor
public struct Button: View {
    private let action: () -> Void
    private let label: AnyView
    private let id: String

    public init(_ title: String, action: @escaping () -> Void) {
        id = UUID().uuidString
        self.action = action
        label = AnyView(Text(title))
        InteractiveComponentRegistry.shared.register(self, withId: id)
    }

    public init(action: @escaping () -> Void, @ViewBuilder label: () -> any View) {
        id = UUID().uuidString
        self.action = action
        self.label = AnyView(label())
        InteractiveComponentRegistry.shared.register(self, withId: id)
    }

    public var body: some View {
        self
    }
}

extension Button: ViewConvertible {
    @MainActor func convertToNode() -> Node {
        // 将 label 转换为 Node
        let labelNode = processView(label)
        return Node(
            id: id,
            type: .button,
            data: ["id": id],
            children: [labelNode] // 添加 label 作为子节点
        )
    }
}

extension Button {
    func handleTap() {
        action()
    }
}

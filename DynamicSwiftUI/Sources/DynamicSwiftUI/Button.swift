//
// DynamicSwiftUI
// Created by: onee on 2024/11/24
//

import Foundation
import DynamicSwiftUITransferProtocol

@MainActor
public struct Button: View {
    private let action: () -> Void
    private let title: String
    private let id: String
    
    public init(_ title: String, action: @escaping () -> Void) {
        self.id = UUID().uuidString
        self.title = title
        self.action = action
        InteractiveComponentRegistry.shared.register(self, withId: id)
    }
    
    public var body: some View {
        self
    }
}

extension Button: ViewConvertible {
    nonisolated func convertToNode() -> Node {
        return Node(id: id,type: .button, data: ["title": title, "id": id])
    }
}

extension Button {
    func handleTap() {
        action()
    }
}

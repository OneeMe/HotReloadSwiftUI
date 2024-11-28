//
// DynamicSwiftUI
// Created by: onee on 2024/11/24
//

import DynamicSwiftUITransferProtocol
import Foundation

@MainActor
public struct AnyView: View {
    private let id: String = UUID().uuidString
    private let _makeView: () -> any View
    
    public init<V: View>(_ view: V) {
        self._makeView = { view }
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

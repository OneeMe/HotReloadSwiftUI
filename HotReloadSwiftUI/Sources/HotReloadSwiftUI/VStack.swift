//
// HotReloadSwiftUI
// Created by: onee on 2024/11/28
//

import Foundation
import HotReloadSwiftUITransferProtocol

@MainActor
public struct VStack<Content: View>: View {
    let id: String = UUID().uuidString
    let content: Content
    let spacing: CGFloat?
    let alignment: HorizontalAlignment

    public init(
        alignment: HorizontalAlignment = .center,
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        self
    }
}

extension VStack: ViewConvertible {
    func convertToNode() -> Node {
        // 将子视图转换为 Node
        let childNode = processView(content)

        // 获取所有子节点
        var children: [Node]
        if childNode.type == .tupleContainer {
            children = childNode.children ?? []
        } else {
            children = [childNode]
        }

        // 构建 VStack 的数据
        var data: [String: String] = [:]
        if let spacing = spacing {
            data["spacing"] = "\(spacing)"
        }
        data["alignment"] = "\(alignment)"

        return Node(
            id: id,
            type: .vStack,
            data: data,
            children: children
        )
    }
}

public enum HorizontalAlignment {
    case leading
    case center
    case trailing
}

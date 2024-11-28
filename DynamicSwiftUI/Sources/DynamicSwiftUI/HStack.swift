//
// DynamicSwiftUI
// Created by: onee on 2024/11/28
//

import DynamicSwiftUITransferProtocol
import Foundation

@MainActor
public struct HStack<Content: View>: View {
    let id: String = UUID().uuidString
    let content: Content
    let spacing: CGFloat?
    let alignment: VerticalAlignment
    
    public init(
        alignment: VerticalAlignment = .center,
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

extension HStack: ViewConvertible {
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
        
        // 构建 HStack 的数据
        var data: [String: String] = [:]
        if let spacing = spacing {
            data["spacing"] = "\(spacing)"
        }
        data["alignment"] = "\(alignment)"
        
        return Node(
            id: id,
            type: .hStack,
            data: data,
            children: children
        )
    }
}

public enum VerticalAlignment {
    case top
    case center
    case bottom
} 

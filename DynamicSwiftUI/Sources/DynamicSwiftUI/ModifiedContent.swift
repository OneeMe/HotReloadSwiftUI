//
// DynamicSwiftUI
// Created by: onee on 2024/11/28
//

import DynamicSwiftUITransferProtocol
import Foundation

@MainActor
public struct ModifiedContent<Content: View, Modifier: ViewModifier>: View {
    let id: String = UUID().uuidString
    let content: Content
    let modifier: Modifier
    
    public init(content: Content, modifier: Modifier) {
        self.content = content
        self.modifier = modifier
    }
    
    public var body: some View {
        self
    }
}

extension ModifiedContent: ViewConvertible {
    func convertToNode() -> Node {
        var childNode = processView(content)
        var nodeModifier: Node.Modifier?
        
        // 根据修饰器类型创建不同的修饰器数据
        if let frameModifier = modifier as? FrameModifier {
            let frameData = Node.FrameData(
                width: frameModifier.width,
                height: frameModifier.height,
                alignment: frameModifier.alignment?.rawValue
            )
            nodeModifier = Node.Modifier(frame: frameData)
        } else if let paddingModifier = modifier as? PaddingModifier {
            let paddingData = Node.PaddingData(
                edges: paddingModifier.edges.description,
                length: paddingModifier.length
            )
            nodeModifier = Node.Modifier(padding: paddingData)
        }
        
        return Node(
            id: childNode.id,
            type: childNode.type,
            data: childNode.data,
            children: childNode.children,
            modifier: nodeModifier
        )
    }
}

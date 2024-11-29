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
            nodeModifier = Node.Modifier(type: .frame, data: .frame(frameData))
        } else if let paddingModifier = modifier as? PaddingModifier {
            let paddingData = Node.PaddingData(
                edges: paddingModifier.edges.description,
                length: paddingModifier.length
            )
            nodeModifier = Node.Modifier(type: .padding, data: .padding(paddingData))
        } else if let labelStyleModifier = modifier as? LabelStyleModifier {
            let labelStyleData = Node.LabelStyleData(style: labelStyleModifier.style.rawValue)
            nodeModifier = Node.Modifier(type: .labelStyle, data: .labelStyle(labelStyleData))
        } else if let clipShapeModifier = modifier as? any ViewModifier {
            if let shape = Mirror(reflecting: clipShapeModifier).children.first?.value as? (any Shape) {
                let clipShapeData = Node.ClipShapeData(shapeType: shape.type.rawValue)
                nodeModifier = Node.Modifier(type: .clipShape, data: .clipShape(clipShapeData))
            }
        } else if let foregroundStyleModifier = modifier as? ForegroundStyleModifier {
            let foregroundStyleData = Node.ForegroundStyleData(color: foregroundStyleModifier.color.rawValue)
            nodeModifier = Node.Modifier(type: .foregroundStyle, data: .foregroundStyle(foregroundStyleData))
        }
        
        // 将新的修饰符添加到现有修饰符列表中
        var modifiers = childNode.modifiers ?? []
        if let nodeModifier = nodeModifier {
            modifiers.append(nodeModifier)
        }
        
        return Node(
            id: childNode.id,
            type: childNode.type,
            data: childNode.data,
            children: childNode.children,
            modifiers: modifiers
        )
    }
}

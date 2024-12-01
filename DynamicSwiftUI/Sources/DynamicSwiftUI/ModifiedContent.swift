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

extension ModifiedContent: ViewConvertible where Content: ViewConvertible {
    func convertToNode() -> Node {
        var node = content.convertToNode()
        
        if let frameModifier = modifier as? FrameModifier {
            let frameData = Node.FrameData(
                width: frameModifier.width,
                height: frameModifier.height,
                alignment: frameModifier.alignment?.rawValue
            )
            node.modifiers = (node.modifiers ?? []) + [
                Node.Modifier(
                    type: .frame,
                    data: .frame(frameData)
                )
            ]
        } else if let paddingModifier = modifier as? PaddingModifier {
            let paddingData = Node.PaddingData(
                edges: paddingModifier.edges.description,
                length: paddingModifier.length
            )
            node.modifiers = (node.modifiers ?? []) + [
                Node.Modifier(
                    type: .padding,
                    data: .padding(paddingData)
                )
            ]
        } else if let clipShapeModifier = modifier as? any AnyClipShapeModifier {
            let shape = clipShapeModifier.shape
            let clipShapeData = Node.ClipShapeData(shapeType: shape.type.rawValue)
            node.modifiers = (node.modifiers ?? []) + [
                Node.Modifier(
                    type: .clipShape,
                    data: .clipShape(clipShapeData)
                )
            ]
        } else if let foregroundStyleModifier = modifier as? ForegroundStyleModifier {
            let style = foregroundStyleModifier.style
            node.modifiers = (node.modifiers ?? []) + [
                Node.Modifier(
                    type: .foregroundStyle,
                    data: .foregroundStyle(Node.ForegroundStyleData(color: style.rawValue))
                )
            ]
        } else if let fontModifier = modifier as? FontModifier {
            node.modifiers = (node.modifiers ?? []) + [
                Node.Modifier(
                    type: .font,
                    data: .font(Node.FontData(style: fontModifier.font.style.rawValue))
                )
            ]
        }
        
        return node
    }
}

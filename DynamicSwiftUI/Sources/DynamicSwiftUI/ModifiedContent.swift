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

extension ModifiedContent: ViewConvertible where Modifier == FrameModifier {
    func convertToNode() -> Node {
        var childNode = processView(content)
        
        // 创建 frame 修饰器数据
        let frameData = Node.FrameData(
            width: modifier.width,
            height: modifier.height,
            alignment: modifier.alignment?.rawValue
        )
        
        // 创建或更新修饰器
        let nodeModifier = Node.Modifier(frame: frameData)
        
        return Node(
            id: childNode.id,
            type: childNode.type,
            data: childNode.data,
            children: childNode.children,
            modifier: nodeModifier
        )
    }
} 

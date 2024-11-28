//
// DynamicSwiftUI
// Created by: onee on 2024/11/24
//

import DynamicSwiftUITransferProtocol
import Foundation

@MainActor
public protocol View {
    associatedtype Body: View
    var body: Self.Body { get }
}

@resultBuilder
public enum ViewBuilder {
    // 单个视图的情况
    public static func buildBlock<Content: View>(_ content: Content) -> Content {
        content
    }
    
    // 使用参数包处理多个视图
    @MainActor
    public static func buildBlock<each Content>(_ content: repeat each Content) -> TupleView<(repeat each Content)> where repeat each Content: View {
        TupleView((repeat each content))
    }
}

// 用于组合多个视图的容器
@MainActor
public struct TupleView<T>: View {
    public let value: T
    
    public init(_ value: T) {
        self.value = value
    }
    
    public var body: some View {
        self
    }
}

// 扩展 TupleView 以支持转换为 Node
extension TupleView: ViewConvertible {
    func convertToNode() -> Node {
        let mirror = Mirror(reflecting: value)
        let children = mirror.children.map { child -> Node in
            let childView = child.value as! any View
            return processView(childView)
        }
        return Node(id: UUID().uuidString, type: .tupleContainer, data: [:], children: children)
    }
}

@MainActor
protocol ViewConvertible {
    func convertToNode() -> Node
}

public extension View {
    @inlinable
    @MainActor func frame(
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        alignment: Alignment = .center
    ) -> ModifiedContent<Self, FrameModifier> {
        ModifiedContent(
            content: self,
            modifier: FrameModifier(
                width: width,
                height: height,
                alignment: alignment
            )
        )
    }

    @inlinable
    @MainActor func padding(
        _ edges: Edge.Set = .all,
        _ length: CGFloat? = nil
    ) -> ModifiedContent<Self, PaddingModifier> {
        ModifiedContent(
            content: self,
            modifier: PaddingModifier(
                edges: edges,
                length: length
            )
        )
    }
}

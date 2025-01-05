//
// HotReloadSwiftUIRunner
// Created by: onee on 2024/11/26
//
import Foundation
import HotReloadSwiftUITransferProtocol

@MainActor
public struct Label<Title: View, Icon: View>: View {
    let title: Title
    let icon: Icon
    var style: LabelStyle = .automatic

    public init(
        _ titleKey: String,
        systemImage: String
    ) where Title == Text, Icon == Image {
        title = Text(titleKey)
        icon = Image(systemName: systemImage)
    }

    public var body: some View {
        self
    }

    public func labelStyle(_ style: LabelStyle) -> Label {
        var copy = self
        copy.style = style
        return copy
    }
}

public enum LabelStyle: String {
    case automatic
    case titleAndIcon
    case titleOnly
    case iconOnly
}

extension Label: ViewConvertible {
    // Label 这里处理的比较特殊，本身是作为一个 shadow view 存在的。
    func convertToNode() -> Node {
        switch style {
        case .automatic, .titleAndIcon:
            // 使用 HStack 布局标题和图标
            let titleNode = processView(title)
            let iconNode = processView(icon)
            return Node(
                id: UUID().uuidString,
                type: .hStack,
                data: ["spacing": "4"],
                children: [iconNode, titleNode]
            )
        case .titleOnly:
            // 只显示标题
            return processView(title)
        case .iconOnly:
            // 只显示图标
            return processView(icon)
        }
    }
}

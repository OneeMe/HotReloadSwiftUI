//
// DynamicSwiftUI
// Created by: onee on 2024/11/28
//

import DynamicSwiftUITransferProtocol
import Foundation

@MainActor
public struct Image: View {
    let id: String = UUID().uuidString
    let imageName: String?
    let systemName: String?
    
    public init(systemName: String) {
        self.systemName = systemName
        self.imageName = nil
    }

    public init(_ name: String, bundle: Bundle? = nil) {
        self.imageName = name
        self.systemName = nil
        // TODO: 添加 bundle 支持
    }
    
    public var body: some View {
        self
    }
}

public enum ImageScale: String {
    case small
    case medium
    case large
}

public enum ForegroundStyle: String {
    case primary
    case secondary
    case tint
}

extension Image: ViewConvertible {
    func convertToNode() -> Node {
        let data: [String: String] = [
            "imageName": imageName ?? "",
            "systemName": systemName ?? "",
        ]
        return Node(id: id, type: .image, data: data)
    }
} 

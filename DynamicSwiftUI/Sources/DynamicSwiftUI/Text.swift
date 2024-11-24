//
// DynamicSwiftUI
// Created by: onee on 2024/11/24
//

public struct Text: View {
    let content: String

    public init(_ content: String) {
        self.content = content
    }

    public var body: Self { self }
}

extension Text: ViewConvertible {
    func convertToNode() -> [String: Any] {
        return [
            "type": "text",
            "data": content
        ]
    }
}

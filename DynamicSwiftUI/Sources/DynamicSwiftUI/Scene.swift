//
// DynamicSwiftUI
// Created by: onee on 2024/11/24
//

public protocol Scene {
    associatedtype Body: Scene
    var body: Self.Body { get }
}

@resultBuilder
public enum SceneBuilder {
    public static func buildBlock<Content: Scene>(_ content: Content) -> Content {
        content
    }
}

public struct WindowGroup: Scene {
    let content: any View

    public init(@ViewBuilder content: () -> any View) {
        self.content = content()
    }

    public var body: Self { self }
}

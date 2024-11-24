//
// DynamicSwiftUI
// Created by: onee on 2024/11/24
//

public protocol App {
    associatedtype Body: Scene
    var body: Self.Body { get }
    init()
}

public extension App {
    static func main() {
        let app = Self()
        runApp(app)
    }
}

//
// DynamicSwiftUI
// Created by: onee on 2024/11/24
//
import DynamicSwiftUITransferProtocol
import Foundation

public protocol App {
    associatedtype Body: Scene
    @MainActor var body: Self.Body { get }
    init()
}

public extension App {
    @MainActor
    static func main() {
        let app = Self()
        runApp(app)
    }
}

@MainActor
func runApp<Root: App>(_ app: Root) {
    let scene = app.body
    
    let viewHierarchy = processScene(app.body)
    let renderData = RenderData(tree: viewHierarchy)
    
    Task {
        await webSocketClient.send(renderData)
    }
    
    print("Application started, entering run loop...")
    
    DispatchQueue.main.async {
        let timer = Timer(timeInterval: TimeInterval.infinity, repeats: true) { _ in }
        RunLoop.current.add(timer, forMode: .common)
    }
    
    RunLoop.main.run()
}

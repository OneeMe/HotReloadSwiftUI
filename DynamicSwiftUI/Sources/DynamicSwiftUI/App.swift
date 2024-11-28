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
    static func main() async {
        let app = Self()
        let _ = try? await runApp(app)
    }
}

@MainActor
func runApp<Root: App>(_ app: Root) async throws {
    let scene = app.body
    
    // 获取启动参数
    let launchData = try await webSocketClient.waitForLaunchData()
    
    // 处理 WindowGroup 场景
    let viewHierarchy = if let windowGroup = scene as? WindowGroup<AnyView> {
        switch windowGroup.contentType {
        case .plain(let content):
            // 普通视图直接处理
            processView(content)
            
        case .parameterized(let presentedContent): {
                // 尝试从启动数据中获取参数，如果没有则使用默认值
                let arg = try? {
                    if !launchData.isEmpty {
                        return try presentedContent.decode(from: launchData)
                    }
                    return presentedContent.defaultValue()
                }()
            
                // 创建绑定
                let binding = Binding(
                    get: { arg },
                    set: { _ in
                        // TOOD: 更新参数
                    }
                )
            
                return processView(presentedContent.content(binding))
            }()
        }
    } else {
        Node(id: "", type: .vStack, data: [:])
    }
    
    let renderData = RenderData(tree: viewHierarchy)
    
    // 发送初始渲染数据
    await webSocketClient.send(renderData)
    
    print("Application started, entering run loop...")
    
    // 创建一个永不完成的 Task 来保持程序运行
    try await withUnsafeThrowingContinuation { (_: UnsafeContinuation<Void, Error>) in
        DispatchQueue.main.async {
            let timer = Timer(timeInterval: TimeInterval.infinity, repeats: true) { _ in }
            RunLoop.current.add(timer, forMode: .common)
            RunLoop.current.run()
        }
    }
}

public enum DynamicAppRegistry {
    private nonisolated(unsafe) static var apps: [String: any App.Type] = [:]
    
    public static func register(name: String, type: any App.Type) {
        apps[name] = type
    }
    
    public static func getApp(name: String) -> (any App.Type)? {
        return apps[name]
    }
    
    public static func createApp(name: String) -> (any App)? {
        guard let appType = apps[name] else { return nil }
        return (appType.init() as? any App)
    }
}

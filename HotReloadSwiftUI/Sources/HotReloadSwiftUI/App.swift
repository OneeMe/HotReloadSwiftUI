//
// HotReloadSwiftUI
// Created by: onee on 2024/11/24
//
import Foundation
import HotReloadSwiftUITransferProtocol

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
    let launchData = try await database.waitForLaunchData()

    // 设置环境值 - 直接使用环境容器中的数据
    setEnvironmentValue(
        launchData.environment.data,
        forType: launchData.environment.id
    )

    var viewHierarchy = Node(id: "", type: .vStack, data: [:])
    // 处理 WindowGroup 场景
    if let windowGroup = Mirror(reflecting: scene).children.first?.value {
        // 使用 Mirror 获取 WindowGroup 的 content 成员
        let windowGroupMirror = Mirror(reflecting: windowGroup)
        if let content = windowGroupMirror.children.first?.value {
            if let content = content as? any View {
                // 普通视图直接处理
                ViewHierarchyManager.shared.setCurrentView(content)
                viewHierarchy = processView(content)
            } else if let presentedContent = content as? AnyPresentedWindowContent {
                viewHierarchy = processParameterizedContent(presentedContent, launchData: launchData.arg)
            } else {
                viewHierarchy = Node(id: "", type: .vStack, data: [:])
            }
        } else {
            viewHierarchy = Node(id: "", type: .vStack, data: [:])
        }
    } else {
        viewHierarchy = Node(id: "", type: .vStack, data: [:])
    }

    let renderData = RenderData(tree: viewHierarchy)

    // 发送初始渲染数据
    let _ = try? await database.send(.execute(.render(renderData)))

    print("Application started, entering run loop...")

    // 在非异步上下文中运行 RunLoop
    try await withUnsafeThrowingContinuation { (_: UnsafeContinuation<Void, Error>) in
        RunLoop.main.run()
    }
}

@MainActor
private func processParameterizedContent(_ presentedContent: AnyPresentedWindowContent, launchData: String) -> Node {
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
            // TODO: 更新参数
        }
    )
    let content = presentedContent.content(binding)
    // TODO: 先放在这里吧
    ViewHierarchyManager.shared.setCurrentView(content)
    return processView(content)
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
        return appType.init()
    }
}

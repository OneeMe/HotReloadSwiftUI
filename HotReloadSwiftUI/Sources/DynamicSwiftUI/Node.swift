/// Node.swift
/// HotReloadSwiftUI
/// Created by: onee on 2024/11/24
///

import Foundation
import HotReloadSwiftUITransferProtocol

@MainActor
@propertyWrapper
public struct State<Value> {
    private let id: String

    public init(wrappedValue: Value) {
        id = UUID().uuidString
        StateManager.shared.setState(id: id, value: wrappedValue)
    }

    public var wrappedValue: Value {
        get {
            return try! StateManager.shared.getState(id: id) as! Value
        }
        nonmutating set {
            Task { @MainActor in
                StateManager.shared.setState(id: id, value: newValue)
                let viewHierarchy = ViewHierarchyManager.shared.getCurrentViewHierarchy()
                let renderData = RenderData(tree: viewHierarchy)
                await webSocketClient.send(.render(renderData))
            }
        }
    }
}

// 组件注册表，保持可交互的组件，方便获取组件信息
@MainActor
final class InteractiveComponentRegistry {
    static let shared = InteractiveComponentRegistry()
    private var components: [String: any ViewConvertible] = [:]

    private init() {}

    func register(_ component: any ViewConvertible, withId id: String) {
        components.updateValue(component, forKey: id)
    }

    func getComponent(withId id: String) -> (any ViewConvertible)? {
        return components[id]
    }

    func clear() {
        components.removeAll()
    }
}

@MainActor
final class StateManager {
    static let shared = StateManager()
    private var states: [String: Any] = [:]

    private init() {}

    func setState(id: String, value: Any) {
        states[id] = value
    }

    func getState(id: String) throws -> Any {
        guard let value = states[id] else {
            throw StateError.stateNotFound
        }
        return value
    }
}

enum StateError: Error {
    case stateNotFound
}

@MainActor
final class ViewHierarchyManager {
    static let shared = ViewHierarchyManager()
    private var currentView: (any View)?

    private init() {}

    func setCurrentView(_ view: any View) {
        currentView = view
        // 清除旧的交互组件注册表
        InteractiveComponentRegistry.shared.clear()
    }

    func getCurrentViewHierarchy() -> Node {
        if let view = currentView {
            return processView(view)
        }
        return Node(id: "", type: .vStack, data: [:])
    }
}

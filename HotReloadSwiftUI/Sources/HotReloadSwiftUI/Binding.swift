//
// HotReloadSwiftUI
// Created by: onee on 2024/11/28
//

import Foundation
import HotReloadSwiftUITransferProtocol

@MainActor
@propertyWrapper
@dynamicMemberLookup
public struct Binding<Value> {
    private let id: String
    private let get: () -> Value
    private let set: (Value) -> Void

    public init(
        get: @escaping () -> Value,
        set: @escaping (Value) -> Void
    ) {
        self.id = UUID().uuidString
        self.get = get
        self.set = set

        // 注册到绑定注册表
        BindingRegistry.shared.register(id: id) { [get, set] newValue in
            if let newValue = newValue as? Value {
                set(newValue)
            }
        }
    }

    public var wrappedValue: Value {
        get { get() }
        nonmutating set { set(newValue) }
    }

    public var projectedValue: Binding<Value> {
        self
    }

    public subscript<Subject>(
        dynamicMember keyPath: WritableKeyPath<Value, Subject>
    ) -> Binding<Subject> {
        Binding<Subject>(
            get: { self.wrappedValue[keyPath: keyPath] },
            set: { self.wrappedValue[keyPath: keyPath] = $0 }
        )
    }
}

public extension Binding {
    static func constant(_ value: Value) -> Binding<Value> {
        Binding(
            get: { value },
            set: { _ in }
        )
    }
}

extension Binding: ViewConvertible where Value: Codable {
    func convertToNode() -> Node {
        var data: [String: String] = [:]
        if let jsonData = try? JSONEncoder().encode(wrappedValue),
           let jsonString = String(data: jsonData, encoding: .utf8)
        {
            data["value"] = jsonString
            data["bindingId"] = id
        }
        return Node(id: id, type: .binding, data: data)
    }
}

// 用于管理绑定的注册表
@MainActor
final class BindingRegistry {
    static let shared = BindingRegistry()
    private var bindings: [String: (Any) -> Void] = [:]

    private init() {}

    func register(id: String, setter: @escaping (Any) -> Void) {
        bindings[id] = setter
    }

    func updateValue(id: String, value: Any) {
        bindings[id]?(value)
    }

    func clear() {
        bindings.removeAll()
    }
}

//
// DynamicSwiftUI
// Created by: onee on 2024/11/28
//

import Foundation
import DynamicSwiftUITransferProtocol
import Combine
import Observation

// 定义环境值容器
@MainActor
public struct EnvironmentValues {
    static var current = EnvironmentValues()
    private var storage: [String: String] = [:]
    private var cache: [String: Any] = [:]
    private var cancellables: Set<AnyCancellable> = []
    mutating func setValue(_ value: String, forType typeName: String) {
        storage[typeName] = value
        cache.removeValue(forKey: typeName)
    }
    
    mutating func getValue<T: Codable>(forType typeName: String) -> T? {
        if let cached = cache[typeName] as? T {
            return cached
        }
        
        guard let jsonString = storage[typeName] else {
            return nil
        }
        
        let decoder = JSONDecoder()
        do {
            if let data = jsonString.data(using: .utf8) {
                let value = try decoder.decode(T.self, from: data)
                if let observableValue = value as? any ObservableObject {
                    let publisher = (observableValue as? any ObservableObject)?.objectWillChange as? ObservableObjectPublisher
                    publisher?.sink { [self] _ in
                        self.updateWebSocket(value: value, typeName: typeName)
                    }
                    .store(in: &cancellables)
                }
                cache[typeName] = value
                return value
            }
        } catch {
            print("Failed to decode value for type: \(typeName), error: \(error)")
        }
        return nil
    }

    private func updateWebSocket(value: any Codable, typeName: String) {
        Task { @MainActor in
            // 发送环境值更新
            if let jsonData = try? JSONEncoder().encode(value),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                let container = EnvironmentContainer(id: typeName, data: jsonString)
                await webSocketClient.send(.environmentUpdate(container))
            }
                
            // 发送渲染数据更新
            let viewHierarchy = ViewHierarchyManager.shared.getCurrentViewHierarchy()
            if !viewHierarchy.data.isEmpty {
                let renderData = RenderData(tree: viewHierarchy)
                await webSocketClient.send(.render(renderData))
            }
        }
    }
}

// 定义环境属性包装器
@propertyWrapper
public struct Environment<Value: Codable>: DynamicProperty {
    private let valueType: Value.Type
    
    public var wrappedValue: Value {
        get {
            let typeName = String(describing: valueType)
            if let value = EnvironmentValues.current.getValue(forType: typeName) as Value? {
                return value
            }
            fatalError("No value found for type: \(typeName)")
        }
    }
    
    public init(_ type: Value.Type) {
        self.valueType = type
    }
}

// 添加环境值设置方法
@MainActor
public func setEnvironmentValue(_ value: String, forType typeName: String) {
    EnvironmentValues.current.setValue(value, forType: typeName)
}

// 添加视图扩展以支持环境值修改
public extension View {
    func environment<T: Codable>(_ value: T) -> some View {
        Task { @MainActor in
            let string = try! JSONEncoder().encode(value).base64EncodedString()
            setEnvironmentValue(string, forType: String(describing: T.self))
        }
        return self
    }
}

// 添加 EnvironmentObject 属性包装器
@propertyWrapper
public struct EnvironmentObject<ObjectType: ObservableObject & Codable>: DynamicProperty {
    private let objectType: ObjectType.Type
    
    public var wrappedValue: ObjectType {
        get {
            let typeName = String(describing: objectType)
            if let value = EnvironmentValues.current.getValue(forType: typeName) as ObjectType? {
                return value
            }
            fatalError("No environment object of type \(typeName) found. A View.environmentObject(_:) modifier must be applied to a parent view.")
        }
    }
    
    public init() {
        self.objectType = ObjectType.self
    }
}

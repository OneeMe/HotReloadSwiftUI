//
// DynamicSwiftUI
// Created by: onee on 2024/11/28
//

import Foundation
import DynamicSwiftUITransferProtocol

// 定义环境值容器
@MainActor
public struct EnvironmentValues {
    static var current = EnvironmentValues()
    private var values: [String: Any] = [:]
    
    // 使用类型名称作为 key
    public subscript<Value>(_ type: Value.Type) -> Value? {
        get { values[String(describing: type)] as? Value }
        set { values[String(describing: type)] = newValue }
    }
    
    // 添加一个通用的设置方法
    mutating func setValue(_ value: Any, forType typeName: String) {
        values[typeName] = value
    }
    
    func getValue(forType typeName: String) -> Any? {
        values[typeName]
    }
}

// 定义环境属性包装器
@propertyWrapper
public struct Environment<Value>: DynamicProperty {
    private let valueType: Value.Type
    
    public init(_ type: Value.Type) {
        self.valueType = type
    }
    
    public var wrappedValue: Value {
        get {
            let typeName = String(describing: valueType)
            guard let value = EnvironmentValues.current.getValue(forType: typeName) as? Value else {
                fatalError("No value found for type \(typeName)")
            }
            return value
        }
        nonmutating set {
            let typeName = String(describing: valueType)
            EnvironmentValues.current.setValue(newValue, forType: typeName)
            // 当环境值发生变化时,自动触发同步
            Task {
                await syncEnvironmentValue(typeName, newValue)
            }
        }
    }
    
    private func syncEnvironmentValue(_ typeName: String, _ value: Any) async {
        if let codableValue = value as? Codable,
           let data = try? JSONEncoder().encode(codableValue) {
            let container = EnvironmentContainer(id: typeName, data: data)
            let message = TransferMessage.environmentUpdate(data)
            if let messageData = try? JSONEncoder().encode(message) {
                let wsMessage = URLSessionWebSocketTask.Message.string(String(data: messageData, encoding: .utf8)!)
                try? await webSocketClient.webSocket?.send(wsMessage)
            }
        }
    }
}

// 添加环境值设置方法
@MainActor
public func setEnvironmentValue(_ value: Any, forType typeName: String) {
    EnvironmentValues.current.setValue(value, forType: typeName)
}

// 添加视图扩展以支持环境值修改
public extension View {
    func environment<T>(_ value: T) -> some View {
        Task { @MainActor in
            setEnvironmentValue(value, forType: String(describing: T.self))
        }
        return self
    }
}

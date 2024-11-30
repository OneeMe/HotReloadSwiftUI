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
    private var storage: [String: String] = [:]
    
    mutating func setValue(_ value: String, forType typeName: String) {
        storage[typeName] = value
    }
    
    func getValue<T: Codable>(forType typeName: String) -> T? {
        guard let jsonString = storage[typeName] else {
            return nil
        }
        print("get value for type: \(typeName), value is \(jsonString)")
        
        // 将 String 解码为具体类型
        let decoder = JSONDecoder()
        do {
            if let data = jsonString.data(using: .utf8) {
                return try decoder.decode(T.self, from: data)
            }
        } catch {
            print("Failed to decode value for type: \(typeName), error is \(error)")
        }
        return nil
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

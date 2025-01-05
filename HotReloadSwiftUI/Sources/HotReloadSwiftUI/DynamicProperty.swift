//
// HotReloadSwiftUI
// Created by: onee on 2024/11/28
//

import Foundation

// 定义 DynamicProperty 协议
@MainActor
public protocol DynamicProperty {
    // 这个协议主要用于标记属性包装器是动态属性
    // SwiftUI 使用这个协议来识别需要触发视图更新的属性
}

//// 添加一些基础的动态属性实现
// @propertyWrapper
// public struct State<Value>: DynamicProperty {
//    private var value: Value
//
//    public init(wrappedValue: Value) {
//        self.value = wrappedValue
//    }
//
//    public var wrappedValue: Value {
//        get { value }
//        nonmutating set {
//            value = newValue
//            // TODO: 触发视图更新
//        }
//    }
//
//    public var projectedValue: Binding<Value> {
//        Binding(
//            get: { wrappedValue },
//            set: { wrappedValue = $0 }
//        )
//    }
// }
//
// @propertyWrapper
// public struct StateObject<ObjectType: ObservableObject>: DynamicProperty {
//    @MainActor private let object: ObjectType
//
//    public init(wrappedValue: ObjectType) {
//        self.object = wrappedValue
//    }
//
//    public var wrappedValue: ObjectType {
//        object
//    }
//
//    public var projectedValue: ObservedObject<ObjectType>.Wrapper {
//        ObservedObject(wrappedValue: object).projectedValue
//    }
// }

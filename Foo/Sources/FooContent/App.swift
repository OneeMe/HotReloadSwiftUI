//
// Foo
// Created by: onee on 2024/11/24
//
#if ENABLE_DYNAMIC_SWIFTUI
import DynamicSwiftUI
#else
import SwiftUI
#endif
import Foundation

// TODO: impl dynamic register
//@DynamicMain("Foo")
public struct FooApp: App {
    // TODO: hide this
    public init() {}

    public var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

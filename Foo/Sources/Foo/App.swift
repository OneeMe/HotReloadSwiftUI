//
// Foo
// Created by: onee on 2024/11/24
//
import DynamicSwiftUI

// TODO: add @DynamicMain to find out the entry of the package
public struct App: DynamicApp {
    // TODO: hide this
    public init() {}

    public var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

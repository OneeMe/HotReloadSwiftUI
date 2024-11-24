// The Swift Programming Language
// https://docs.swift.org/swift-book

import DynamicSwiftUI

@main 
struct Foo: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        Text("Hello, This is from Foo~~~")
    }
}

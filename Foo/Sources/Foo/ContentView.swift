//
// Foo
// Created by: onee on 2024/11/24
//
#if ENABLE_DYNAMIC_SWIFTUI
import DynamicSwiftUI
#else
import SwiftUI
#endif

public struct ContentView: View {
    @State var count = 0
    
    public init() {}
    
    public var body: some View {
        Button("Button From Foo: count: \(count)") {
            print("count is \(count)")
            count += 1
        }
    }
}

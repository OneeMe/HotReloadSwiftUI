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
        VStack {
            Image("turtlerock")
            Button("Button\(count)") {
                count += 1
            }
            Divider()
            Button("Button \(count)") {
                count += 1
            }
        }
    }
}

#if !ENABLE_DYNAMIC_SWIFTUI
#Preview {
    ContentView()
}
#endif

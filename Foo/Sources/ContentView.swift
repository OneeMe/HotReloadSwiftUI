//
// Foo
// Created by: onee on 2024/11/24
//
import DynamicSwiftUI

struct ContentView: View {
    @State var count = 0
    
    var body: some View {
        Button("Button From Foo: count: \(count)") {
            count += 1
        }
    }
}

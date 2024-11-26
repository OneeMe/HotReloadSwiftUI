//
// Example
// Created by: onee on 2024/11/24
//

import DynamicSwiftUIRunner
import SwiftUI
import Foo

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            DynamicSwiftUIRunner(id: "Foo", content: Foo.ContentView())
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

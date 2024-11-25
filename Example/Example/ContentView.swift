//
// Example
// Created by: onee on 2024/11/24
//

import DynamicSwiftUIRunner
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            DynamicSwiftUIRunner(id: "Foo")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

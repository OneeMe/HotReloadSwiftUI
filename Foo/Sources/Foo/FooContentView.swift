//
// Foo
// Created by: onee on 2024/11/26
//

import SwiftUI
import DynamicSwiftUIRunner
import FooContent

public struct FooContentView: View {
    public init() {}
    
    public var body: some View {
        DynamicSwiftUIRunner(id: "Foo", content: FooContent.ContentView() as! (any View))
    }
}

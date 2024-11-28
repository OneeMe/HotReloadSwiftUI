//
// Foo
// Created by: onee on 2024/11/26
//

import SwiftUI
import DynamicSwiftUIRunner
import FooContent

public struct FooLandmarkDetail: View {
    let landmark: Landmark
    
    public init(landmark: Landmark) {
        self.landmark = landmark
    }
    
    public var body: some View {
        DynamicSwiftUIRunner(id: "Foo", arg: landmark, content: FooContent.LandmarkDetail(landmark: landmark) as! (any View))
    }
}

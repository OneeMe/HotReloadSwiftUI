//
// Foo
// Created by: onee on 2024/11/26
//

import SwiftUI
import DynamicSwiftUIRunner
import FooContent

public struct FooLandmarkDetail: View {
    let landmark: Landmark
    @Environment(ModelData.self) var modelData
    
    public init(landmark: Landmark) {
        self.landmark = landmark
    }
    
    public var body: some View {
        DynamicSwiftUIRunner(id: "Foo", arg: landmark, environment: modelData, environmentUpdater: { newValue in
            modelData.landmarks = newValue.landmarks
        }) { arg in
            LandmarkDetail(landmark: arg)
        }
    }
}

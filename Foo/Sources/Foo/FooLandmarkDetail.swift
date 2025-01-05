//
// Foo
// Created by: onee on 2024/11/26
//

import FooContent
import HotReloadSwiftUIRunner
import SwiftUI

public struct FooLandmarkDetail: View {
    let landmark: Landmark
    @EnvironmentObject var modelData: ModelData

    public init(landmark: Landmark) {
        self.landmark = landmark
    }

    public var body: some View {
        HotReloadSwiftUIRunner(id: "Foo", arg: landmark, environment: modelData, environmentUpdater: { newValue in
            modelData.landmarks = newValue.landmarks
        }) { arg in
            LandmarkDetail(landmark: arg)
        }
    }
}

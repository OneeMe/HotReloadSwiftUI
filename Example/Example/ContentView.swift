//
// Example
// Created by: onee on 2024/11/24
//

import DynamicSwiftUIRunner
import SwiftUI
import Foo
import FooContent

struct ContentView: View {
    @Environment(ModelData.self) var modelData
    @State private var showFavoritesOnly = false

    var filteredLandmarks: [Landmark] {
        modelData.landmarks.filter { landmark in
            (!showFavoritesOnly || landmark.isFavorite)
        }
    }

    var body: some View {
        NavigationSplitView {
            List {
                Toggle(isOn: $showFavoritesOnly) {
                    Text("Favorites only")
                }

                ForEach(filteredLandmarks) { landmark in
                    NavigationLink {
                        FooLandmarkDetail(landmark: landmark)
                    } label: {
                        LandmarkRow(landmark: landmark)
                    }
                }
            }
            .animation(.default, value: filteredLandmarks)
            .navigationTitle("Landmarks（宿主 App）")
        } detail: {
            Text("Select a Landmark")
        }
    }
}

#Preview {
    ContentView()
}

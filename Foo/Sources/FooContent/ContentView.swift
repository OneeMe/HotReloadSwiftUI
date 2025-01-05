//
// Foo
// Created by: onee on 2024/11/24
//
#if ENABLE_DYNAMIC_SWIFTUI
    import HotReloadSwiftUI
#else
    import MapKit
    import SwiftUI
#endif

public struct LandmarkDetail: View {
    @EnvironmentObject var modelData: ModelData
    var landmark: Landmark

    var landmarkIndex: Int {
        modelData.landmarks.firstIndex(where: { $0.id == landmark.id })!
    }

    public init(landmark: Landmark) {
        self.landmark = landmark
    }

    public var body: some View {
        VStack {
            landmark
                .image
                .padding(.bottom, -130)
                .clipShape(Circle())

            VStack(alignment: .leading) {
                HStack {
                    Text(landmark.name)
                        .font(.title)

                    Button {
                        modelData.landmarks[landmarkIndex].isFavorite.toggle()
                    } label: {
                        Label("Toggle Favorite", systemImage: modelData.landmarks[landmarkIndex].isFavorite ? "star.fill" : "star")
                            .labelStyle(.iconOnly)
                            .foregroundStyle(modelData.landmarks[landmarkIndex].isFavorite ? .yellow : .gray)
                    }
                }

                HStack {
                    Text(landmark.park)

                    Text(landmark.state)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                Divider()

                Text("About \(landmark.name)")
                    .font(.title2)
                Text(landmark.description)
            }
            .padding()
        }
    }
}

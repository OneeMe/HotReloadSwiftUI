//
// Foo
// Created by: onee on 2024/11/24
//
#if ENABLE_DYNAMIC_SWIFTUI
import DynamicSwiftUI
#else
import MapKit
import SwiftUI
#endif

public struct LandmarkDetail: View {
    @Environment(ModelData.self) var modelData
    var landmark: Landmark

    var landmarkIndex: Int {
        modelData.landmarks.firstIndex(where: { $0.id == landmark.id })!
    }
    
    public init(landmark: Landmark) {
        self.landmark = landmark
    }

    public var body: some View {
        VStack {
            //        @Bindable var modelData = modelData
            //
            //        Map(position: .constant(.region(
            //            MKCoordinateRegion(
            //                center: landmark.locationCoordinate,
            //                span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
            //            )
            //        )))
            //        .frame(height: 300)
            
           landmark
               .image
               .padding(.bottom, -130)
               .clipShape(Circle())
            //    .offset(y: -130)
            
            VStack(alignment: .leading) {
                HStack {
                    Text(landmark.name)
                    //                    .font(.title)
                    
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
                //            .font(.subheadline)
                //            .foregroundStyle(.secondary)
                
                Divider()
                
                Text("About \(landmark.name)")
                //                .font(.title2)
                Text(landmark.description)
            }
            .padding()
        }
//        .navigationTitle(landmark.name)
//        .navigationBarTitleDisplayMode(.inline)
    }
}

#if !ENABLE_DYNAMIC_SWIFTUI
#Preview {
    LandmarkDetail(landmark: defaultLandMark)
}
#endif

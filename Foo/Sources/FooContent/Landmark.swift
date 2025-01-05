/*
 See the LICENSE.txt file for this sample’s licensing information.

 Abstract:
 A representation of a single landmark.
 */

import CoreLocation
import Foundation
#if ENABLE_DYNAMIC_SWIFTUI
    import HotReloadSwiftUI
#else
    import SwiftUI
#endif

public struct Landmark: Hashable, Codable, Identifiable, Sendable {
    public var id: Int
    public var name: String
    public var park: String
    public var state: String
    public var description: String
    public var isFavorite: Bool

    private var imageName: String
    @MainActor
    public var image: Image {
        Image(imageName)
    }

    private var coordinates: Coordinates
    var locationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: coordinates.latitude,
            longitude: coordinates.longitude
        )
    }

    struct Coordinates: Hashable, Codable {
        var latitude: Double
        var longitude: Double
    }

    init(id: Int, name: String, park: String, state: String, description: String, isFavorite: Bool, imageName: String, coordinates: Coordinates) {
        self.id = id
        self.name = name
        self.park = park
        self.state = state
        self.description = description
        self.isFavorite = isFavorite
        self.imageName = imageName
        self.coordinates = coordinates
    }
}

let defaultLandMark: Landmark = .init(
    id: 0,
    name: "Turtle Rock",
    park: "Joshua Tree National Park",
    state: "California",
    description: "A small rock formation with a distinctive split.",
    isFavorite: true,
    imageName: "turtle-rock",
    coordinates: .init(
        latitude: 34.011286,
        longitude: -116.166868
    )
)

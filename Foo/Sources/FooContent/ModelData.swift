/*
 See the LICENSE.txt file for this sample’s licensing information.

 Abstract:
 Storage for model data.
 */

import Foundation

@Observable
public class ModelData {
    public var landmarks: [Landmark] = []

    public init(landmarks: [Landmark]) {
        self.landmarks = landmarks
    }
}

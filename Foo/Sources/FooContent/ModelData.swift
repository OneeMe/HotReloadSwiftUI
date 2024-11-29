/*
 See the LICENSE.txt file for this sample’s licensing information.

 Abstract:
 Storage for model data.
 */

import Foundation

@Observable
public class ModelData: Codable { // TODO: 目前实现方案需要让 Observable 额外支持 Codable
    public var landmarks: [Landmark] = []

    public init(landmarks: [Landmark]) {
        self.landmarks = landmarks
    }
}

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

    // 自定义编码方法
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(landmarks, forKey: .landmarks)
    }
    
    // 自定义解码方法
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        landmarks = try container.decode([Landmark].self, forKey: .landmarks)
    }
    
    private enum CodingKeys: String, CodingKey {
        case landmarks
    }
}

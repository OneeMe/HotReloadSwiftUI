//
// HotReloadSwiftUITransferProtocol
// Created by: onee on 2025/1/6
//
import Foundation

public struct ClientUnitId: Codable, CustomStringConvertible {
    public let package: String
    public let unit: String
    public let instanceDate: Date

    public var description: String {
        let dateFormatter = ISO8601DateFormatter()
        return "\(package)/\(unit)/\(dateFormatter.string(from: instanceDate))"
    }
}

public struct DatabaseUnitId: Codable {
    public let package: String
    public let units: Set<String>
}

public enum Role: Codable {
    case database(id: DatabaseUnitId)
    case client(id: ClientUnitId)
}

public struct RegisterTransferMessage: Codable {
    public let role: Role
    public let deviceInfo: String?
}

import Foundation

public struct LaunchData: Codable, Sendable {
    public let arg: String
    public let environment: EnvironmentContainer

    public init(arg: String, environment: EnvironmentContainer) {
        self.arg = arg
        self.environment = environment
    }
}

//
// HotReloadInspector
// Created by: onee on 2025/1/6
//
import HotReloadSwiftUITransferProtocol
import Swifter

class Client: Hashable {
    let clientId: ClientUnitId
    let name: String
    let session: WebSocketSession
    var lastLaunchData: LaunchData?
    var interactiveHistory: [InteractiveData]

    init(clientId: ClientUnitId, name: String, session: WebSocketSession) {
        self.clientId = clientId
        self.name = name
        self.session = session
        lastLaunchData = nil
        interactiveHistory = []
    }

    static func == (lhs: Client, rhs: Client) -> Bool {
        lhs.clientId.package == rhs.clientId.package &&
            lhs.clientId.unit == rhs.clientId.unit &&
            lhs.clientId.instanceDate == rhs.clientId.instanceDate
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(clientId.package)
        hasher.combine(clientId.unit)
        hasher.combine(clientId.instanceDate)
    }
}

extension Client {
    var shortId: String {
        "\(clientId.package)/\(clientId.unit)"
    }
}

//
// HotReloadInspector
// Created by: onee on 2025/1/6
//

import Foundation
import HotReloadSwiftUITransferProtocol
import Swifter

enum ConnectionStatus: Hashable {
    case connected
    case disconnected
}

struct Connection: Identifiable {
    let database: Database
    let client: Client
    var status: ConnectionStatus

    var id: String {
        "\(database.id)_\(client.id)"
    }

    var deviceInfo: String {
        client.name
    }
}

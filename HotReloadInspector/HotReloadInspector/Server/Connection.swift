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

class Connection: Identifiable {
    let database: Database
    let client: Client
    var status: ConnectionStatus

    var id: String {
        "\(database.databaseId)_\(client.clientId)"
    }

    var deviceInfo: String {
        client.name
    }
    
    public init(database: Database, client: Client, status: ConnectionStatus) {
        self.database = database
        self.client = client
        self.status = status
    }
}

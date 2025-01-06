//
// HotReloadInspector
// Created by: onee on 2025/1/6
//
import Foundation
import HotReloadSwiftUITransferProtocol
import Swifter

struct Database: Identifiable, Hashable {
    let databaseId: DatabaseUnitId
    let session: WebSocketSession

    var id: String {
        databaseId.package
    }

    var name: String {
        databaseId.package
    }

    static func == (lhs: Database, rhs: Database) -> Bool {
        lhs.databaseId.package == rhs.databaseId.package
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(databaseId.package)
    }

    init(id: DatabaseUnitId, session: WebSocketSession) {
        databaseId = id
        self.session = session
    }
}

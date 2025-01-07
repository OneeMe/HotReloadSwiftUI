//
// HotReloadInspector
// Created by: onee on 2025/1/6
//
import Foundation
import HotReloadSwiftUITransferProtocol
import Swifter

struct Database: Hashable, Identifiable {
    static func == (lhs: Database, rhs: Database) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    var id: String { databaseId.package }

    let databaseId: DatabaseUnitId
    let session: WebSocketSession
    var lastRenderData: RenderData?
    var lastEnvironmentUpdate: EnvironmentContainer?

    init(databaseId: DatabaseUnitId, session: WebSocketSession) {
        self.databaseId = databaseId
        self.session = session
        lastRenderData = nil
        lastEnvironmentUpdate = nil
    }
}

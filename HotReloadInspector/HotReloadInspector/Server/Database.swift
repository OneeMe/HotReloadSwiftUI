//
// HotReloadInspector
// Created by: onee on 2025/1/6
//
import Foundation
import HotReloadSwiftUITransferProtocol
import Swifter

// 为了确保 lastEnvironmentUpdate 和 lastRenderData 使用不同的 reference
// 都可以正确同步，我们需要将 Database 和 Client 都设置为 class 而不是 struct
class Database: Hashable, Identifiable {
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

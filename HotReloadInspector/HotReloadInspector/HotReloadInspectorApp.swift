//
// HotReloadInspector
// Created by: onee on 2025/1/5
//

import SwiftUI
import SwiftData

@main
struct HotReloadInspectorApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView(databases: [:])
        }
        .modelContainer(sharedModelContainer)
    }
}

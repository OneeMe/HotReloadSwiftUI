//
// HotReloadInspector
// Created by: onee on 2025/1/5
//

import SwiftUI

@main
struct HotReloadInspectorApp: App {
    @StateObject private var inspectorServer = InspectorServer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(inspectorServer)
        }
    }
}

//
// HotReloadInspector
// Created by: onee on 2025/1/5
//

import Combine
import HotReloadSwiftUITransferProtocol
import SwiftData
import Swifter
import SwiftUI

struct StatusIndicator: View {
    let status: ConnectionStatus

    var body: some View {
        Circle()
            .fill(status.color)
            .frame(width: 12, height: 12)
    }
}

struct ConnectionRow: View {
    let connection: Connection

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(connection.deviceInfo) - \(connection.client.clientId)")
                    .font(.system(size: 16, weight: .medium))
            }
            Spacer()
            StatusIndicator(status: connection.status)
        }
        .padding(.vertical, 8)
    }
}

struct DatabaseRow: View {
    let database: Database
    let connections: [Connection]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(database.id)
                .font(.system(size: 16, weight: .medium))
            Text("\(connections.count) clients")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
}

struct ContentView: View {
    @EnvironmentObject private var server: InspectorServer
    @State private var selectedDatabase: Database?

    var databaseConnections: [String: [Connection]] {
        Dictionary(grouping: server.connections.values) { $0.database.id }
    }

    var body: some View {
        NavigationSplitView {
            List(Array(server.databases.values), selection: $selectedDatabase) { database in
                DatabaseRow(
                    database: database,
                    connections: databaseConnections[database.id] ?? []
                )
                .tag(database)
            }
            .navigationTitle("DataBase List")
            .navigationSplitViewColumnWidth(min: 180, ideal: 300)
            .listStyle(.plain)
        } detail: {
            if let database = selectedDatabase {
                List(databaseConnections[database.id] ?? []) { connection in
                    ConnectionRow(connection: connection)
                }
                .navigationTitle("\(database.id) Connected Status")
                .listStyle(.plain)
            } else {
                Text("Select a database")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
            }
        }
        .preferredColorScheme(.dark)
    }
}

extension ConnectionStatus {
    var color: Color {
        switch self {
        case .connected:
            return .green
        case .disconnected:
            return .red
        }
    }
}

//
// HotReloadInspector
// Created by: onee on 2025/1/5
//

import SwiftData
import SwiftUI

enum ConnectionStatus: Hashable {
    case connected
    case disconnected

    var color: Color {
        switch self {
        case .connected:
            return .green
        case .disconnected:
            return .red
        }
    }
}

struct Database: Identifiable, Hashable {
    let id = UUID()
    let name: String
    var clients: [Connection]

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Database, rhs: Database) -> Bool {
        lhs.id == rhs.id
    }
}

struct Connection: Identifiable, Hashable {
    let id = UUID()
    let deviceInfo: String
    var status: ConnectionStatus

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Connection, rhs: Connection) -> Bool {
        lhs.id == rhs.id
    }
}

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
                Text(connection.deviceInfo)
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

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(database.name)
                .font(.system(size: 16, weight: .medium))
            Text("\(database.clients.count) clients")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
}

struct ContentView: View {
    @State var databases: [String: Database] = [:]
    @State private var selectedDatabase: Database?

    var body: some View {
        NavigationSplitView {
            List(Array(databases.values), selection: $selectedDatabase) { database in
                DatabaseRow(database: database)
                    .tag(database)
            }
            .navigationTitle("DataBase List")
            .navigationSplitViewColumnWidth(min: 180, ideal: 300)
            .listStyle(.plain)
        } detail: {
            if let database = selectedDatabase {
                List(database.clients) { client in
                    ConnectionRow(connection: client)
                }
                .navigationTitle("\(database.name) Connected Status")
                .listStyle(.plain)
            } else {
                Text("Select a database")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
            }
        }
        .preferredColorScheme(.dark)
    }

    init(databases: [String: Database]) {
        _databases = State(initialValue: databases)
    }
}

#Preview {
    let previewDatabase = Database(name: "Foo", clients: [
        Connection(deviceInfo: "iPhone 16 (Simulator)", status: .connected),
        Connection(deviceInfo: "iPad 4 (Simulator)", status: .disconnected),
        Connection(deviceInfo: "mac (Device)", status: .disconnected),
    ])

    return ContentView(databases: ["Foo": previewDatabase])
}

//
//  PatfiApp.swift
//  Patfi
//
//  Created by Mathieu Vandeginste on 04/09/2025.
//

import SwiftUI
import SwiftData

@main
struct PatfiApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedContainer)
    }
}

let sharedContainer: ModelContainer = {
    let schema = Schema([Account.self, BalanceSnapshot.self])
#if targetEnvironment(simulator)
    let config = ModelConfiguration(schema: schema, cloudKitDatabase: .none)
#else
    let config = ModelConfiguration(schema: schema, cloudKitDatabase: .private("iCloud.fr.matvdg.patfi"))
#endif
    do {
        return try ModelContainer(for: schema, configurations: [config])
    } catch {
        fatalError("Failed to load SwiftData ModelContainer: \(error)")
    }
}()

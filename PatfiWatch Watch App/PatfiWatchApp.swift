import SwiftUI
import SwiftData

@main
struct PatfiWatch_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            WatchMainView()
                .modelContainer(for: [Account.self, BalanceSnapshot.self, Bank.self], isAutosaveEnabled: true, isUndoEnabled: false)

        }
    }
}

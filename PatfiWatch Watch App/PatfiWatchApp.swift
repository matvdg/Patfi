import SwiftUI
import SwiftData

@main
struct PatfiWatch_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            WatchMainView()
                .modelContainer(sharedContainer)

        }
    }
}

let sharedContainer: ModelContainer = {
    let schema = Schema([Account.self, BalanceSnapshot.self, Bank.self])
#if targetEnvironment(simulator)
    let config = ModelConfiguration(schema: schema, cloudKitDatabase: .none)
#else
    let config = ModelConfiguration(schema: schema, cloudKitDatabase: .private(iCloudID))
#endif
    do {
        return try ModelContainer(for: schema, configurations: [config])
    } catch {
        fatalError("Failed to load SwiftData ModelContainer: \(error)")
    }
}()

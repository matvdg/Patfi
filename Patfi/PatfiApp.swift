import TipKit
import SwiftUI
import SwiftData

@main
struct PatfiApp: App {
            
    var body: some Scene {
        
        WindowGroup {
            AccountsDashboardView()
                .onAppear {
                    try? Tips.configure()
                }
        }
        .modelContainer(sharedContainer)
    }
}

let sharedContainer: ModelContainer = {
    let schema = Schema([Account.self, BalanceSnapshot.self, Bank.self])
#if targetEnvironment(simulator)
    let config = ModelConfiguration(schema: schema, cloudKitDatabase: .none)
#else
    let config = ModelConfiguration(schema: schema, cloudKitDatabase: .private(AppIDs.iCloudID))
#endif
    do {
        return try ModelContainer(for: schema, configurations: [config])
    } catch {
        fatalError("Failed to load SwiftData ModelContainer: \(error)")
    }
}()

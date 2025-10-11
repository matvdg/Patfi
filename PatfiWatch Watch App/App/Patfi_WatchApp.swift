import SwiftUI
import SwiftData

@main
struct PatfiWatch_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
                .modelContainer(ModelContainer.shared)
        }
    }
}

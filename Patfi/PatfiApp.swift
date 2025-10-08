import SwiftUI
import SwiftData

@main
struct PatfiApp: App {
            
    var body: some Scene {
        
        WindowGroup {
            HomeView()
        }
        .modelContainer(ModelContainer.getSharedContainer())
    }
}

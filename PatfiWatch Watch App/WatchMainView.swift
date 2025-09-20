import SwiftUI
import SwiftData

struct WatchMainView: View {
    
    @Environment(\.modelContext) private var context
    @Query(sort: \Account.name, order: .forward) private var accounts: [Account]
    let repo = BalanceRepository()
    
    var body: some View {
        TabView {
            if repo.balance(for: accounts).isZero {
                TotalWidgetView()
            } else {
                TotalWidgetView()
                BanksWidgetView()
                CategoriesWidgetView()
                PieChartWidgetView()
            }
        }
        .tabViewStyle(.verticalPage)
        .task {
            do {
                _ = try context.fetch(FetchDescriptor<Account>())
                _ = try context.fetch(FetchDescriptor<BalanceSnapshot>())
                _ = try context.fetch(FetchDescriptor<Bank>())
            } catch {
                print("Erreur de refresh CloudKit: \(error)")
            }
        }
    }
}

#Preview {
    WatchMainView()
}

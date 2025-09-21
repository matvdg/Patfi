import SwiftUI
import SwiftData

struct WatchMainView: View {
    
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
    }
}

#Preview {
    WatchMainView()
}

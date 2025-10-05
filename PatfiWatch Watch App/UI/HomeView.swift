import SwiftUI
import SwiftData

struct HomeView: View {
    
    @Query(sort: \Account.name, order: .forward) private var accounts: [Account]
    private let repo = BalanceRepository()
    
    var body: some View {
        TabView {
            if repo.balance(for: accounts).isZero {
                TotalView()
            } else {
                TotalView()
                AccountsView()
                BanksView()
                CategoriesView()
                PieChartView()
                TotalChartView()
            }
        }
        .tabViewStyle(.verticalPage)
    }
}

#Preview {
    HomeView()
        .modelContainer(ModelContainer.getSharedContainer())
}

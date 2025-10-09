import SwiftUI
import SwiftData

struct HomeView: View {
    
    @Query(sort: \Account.name, order: .forward) private var accounts: [Account]
    private let balanceRepository = BalanceRepository()
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 8) {
                TotalView()
                HStack(alignment: .center, spacing: 8) {
                    NavigationLink {
                        AccountsView()
                    } label: {
                        Image(systemName: "list.bullet")
                    }
                    NavigationLink {
                        BanksView()
                    } label: {
                        Image(systemName: Bank.sfSymbol)
                    }
                    NavigationLink {
                        PieView()
                    } label: {
                        Image(systemName: "chart.pie")
                    }
                    NavigationLink {
                        BarView()
                    } label: {
                        Image(systemName: "chart.bar")
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        NavigationLink {
                            AddAccountView()
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            
        }
        
    }
}

#Preview {
    HomeView()
        .modelContainer(ModelContainer.getSharedContainer())
}

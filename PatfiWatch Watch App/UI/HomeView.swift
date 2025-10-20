import SwiftUI
import SwiftData

struct HomeView: View {
    
    @Query(sort: \Account.name, order: .forward) private var accounts: [Account]
    @State private var showActions = false
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
                        FilteredTransactionsView()
                    } label: {
                        Image(systemName: "receipt")
                    }
                }
                HStack(alignment: .center, spacing: 8) {
                    NavigationLink {
                        PieView()
                    } label: {
                        Image(systemName: "chart.pie")
                    }
                    Button {
                        showActions = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.glassProminent)
                    NavigationLink {
                        BarView()
                    } label: {
                        Image(systemName: "chart.bar")
                    }
                }
                .confirmationDialog("add", isPresented: $showActions) {
                    ForEach(QuickAction.allCases, id: \.self) { action in
                        // If there are no accounts, skip actions that require an account
                        if accounts.isEmpty && action.requiresAccount {
                            // Skip
                        } else {
                            NavigationLink(action.localizedTitle) {
                                action.destinationView()
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(ModelContainer.shared)
}

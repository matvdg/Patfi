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
                        Button {
                            showActions = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .confirmationDialog("Add", isPresented: $showActions) {
                    NavigationLink("Account") { AddAccountView() }
//                    NavigationLink("Balance") { AddBalanceView() }
                    NavigationLink("Expense") { AddExpenseView() }
                    NavigationLink("Income") { AddIncomeView() }
                    NavigationLink("Internal transfer") { AddInternalTransferView() }
                    NavigationLink("Bank") { EditBankView() }
                }
            }
            
        }
        
    }
}

#Preview {
    HomeView()
        .modelContainer(ModelContainer.getSharedContainer())
}

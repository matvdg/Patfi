import SwiftUI
import SwiftData

struct BanksWidgetView: View {
    
    @Query(sort: \Account.name, order: .forward) private var accounts: [Account]
    let repo = BalanceRepository()
    
    var body: some View {
                
        if repo.balance(for: accounts).isZero {
            EmptyView()
        } else {
            VStack(alignment: .leading, spacing: 4) {
                Spacer()
                let sorted = repo.groupByBank(accounts).sorted { $0.key.name < $1.key.name }
                let totalBalance = repo.balance(for: accounts)
                ForEach(sorted, id: \.key) { bank, bankAccounts in
                    let total = repo.balance(for: bankAccounts)
                    HStack {
                        BankRow(bank: bank)
                            .minimumScaleFactor(0.3)
                        Spacer()
                        Text(total.toString)
                            .minimumScaleFactor(0.3)
                    }
                }
                Spacer()
            }
            .padding()
            .padding()
        }
    }
}

#Preview {
    BanksWidgetView()
}

import SwiftUI
import SwiftData

struct BanksView: View {
    
    @Query(sort: \Account.name, order: .forward) private var accounts: [Account]
    private let repo = BalanceRepository()
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 4) {
            Spacer()
            let sorted = repo.groupByBank(accounts)
                .map { ($0.key, repo.balance(for: $0.value))}
                .sorted { $0.1 > $1.1 }
            ForEach(sorted, id: \.0) { bank, total in
                HStack {
                    BankRow(bank: bank)
                    Spacer()
                    Text(total.toString)
                        .lineLimit(1)
                        .minimumScaleFactor(0.1)
                }
            }
            Spacer()
        }
        .padding()
        .padding()
        
    }
}

#Preview {
    BanksView()
        .modelContainer(ModelContainer.getSharedContainer())
}

import SwiftUI
import SwiftData

struct TotalView: View {
    
    @Query(sort: \Account.name, order: .forward) private var accounts: [Account]
    private let repo = BalanceRepository()
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            let balance = repo.balance(for: accounts)
            HStack(alignment: .center, spacing: 8) {
                Bank.sfSymbol
                Text("Patfi")
                    .font(.headline)
            }
            Text(balance.toString)
                .font(.largeTitle)
                .bold()
                .minimumScaleFactor(0.2)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    TotalView()
}

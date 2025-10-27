import SwiftUI
import SwiftData

struct HomeTotalView: View {
    
    @Query(sort: \Account.name, order: .forward) private var accounts: [Account]
    private let balanceRepository = BalanceRepository()
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            let balance = balanceRepository.balance(for: accounts)
            AmountText(amount: balance)
                .font(.largeTitle)
                .bold()
                .minimumScaleFactor(0.2)
                .lineLimit(1)
        }
        .padding()
    }
}

#Preview {
    HomeTotalView()
        .modelContainer(ModelContainer.shared)
}

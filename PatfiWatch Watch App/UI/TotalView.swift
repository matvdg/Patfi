import SwiftUI
import SwiftData

struct TotalView: View {
    
    @Query(sort: \Account.name, order: .forward) private var accounts: [Account]
    private let balanceRepository = BalanceRepository()
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            let balance = balanceRepository.balance(for: accounts)
            Text(balance.toString)
                .font(.largeTitle)
                .bold()
                .minimumScaleFactor(0.2)
                .lineLimit(1)
        }
        .padding()
    }
}

#Preview {
    TotalView()
        .modelContainer(ModelContainer.shared)
}

import SwiftUI
import SwiftData

struct CategoriesWidgetView: View {
    
    @Query(sort: \Account.name, order: .forward) private var accounts: [Account]
    let repo = BalanceRepository()
    
    var body: some View {
        VStack {
            let sorted = repo.groupByCategory(accounts).sorted { $0.key.localizedCategory < $1.key.localizedCategory }
            ForEach(sorted, id: \.key) { cat, catAccounts in
                HStack {
                    HStack(spacing: 8) {
                        Circle().fill(cat.color).frame(width: 10, height: 10)
                        Text(cat.localizedName).minimumScaleFactor(0.5)
                    }
                    Spacer()
                    Text(repo.balance(for: catAccounts).toString)
                        .minimumScaleFactor(0.5)
                }
            }
        }
        .padding()
    }
}

#Preview {
    CategoriesWidgetView()
}

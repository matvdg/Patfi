import SwiftUI
import SwiftData

struct CategoriesView: View {
    
    @Query(sort: \Account.name, order: .forward) private var accounts: [Account]
    private let repo = BalanceRepository()
    
    var body: some View {
        VStack {
            let sorted = repo.groupByCategory(accounts)
                .map {
                    ($0.key, repo.balance(for: $0.value))
                }
                .sorted { $0.1 > $1.1 }

            ForEach(sorted, id: \.0) { cat, total in
                HStack {
                    HStack(spacing: 8) {
                        Circle().fill(cat.color).frame(width: 10, height: 10)
                        Text(cat.localizedName)
                            .lineLimit(1)
                            .minimumScaleFactor(0.1)
                    }
                    Spacer()
                    Text(total.toString)
                        .lineLimit(1)
                        .minimumScaleFactor(0.1)
                }
            }
        }
        .padding()
    }
}

#Preview {
    CategoriesView()
        .modelContainer(ModelContainer.getSharedContainer())
}

import SwiftUI
import Charts
import SwiftData

struct PieChartView: View {
    
    @Query(sort: \Account.name, order: .forward) private var accounts: [Account]
    private let repo = BalanceRepository()
    
    var body: some View {
        Chart {
            let sorted = repo.groupByCategory(accounts)
                .sorted { $0.key.localizedCategory < $1.key.localizedCategory }
            ForEach(sorted, id: \.key) { category, catAccounts in
                SectorMark(
                    angle: .value("Total", repo.balance(for: catAccounts)),
                    innerRadius: .ratio(0.6),
                    angularInset: 1.0
                )
                .foregroundStyle(category.color)
            }
        }
    }
}

#Preview {
    PieChartView()
}

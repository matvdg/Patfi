import SwiftUI
import SwiftData
import Charts

struct DashboardPieChartView: View {
    @Query(sort: [SortDescriptor(\Account.name, order: .forward)])
    private var accounts: [Account]
    private let repo = BalanceRepository()

    var body: some View {
        // Group accounts by category and sum latest balances for each category
        let grouped = repo.groupByCategory(accounts)
        let slices: [Slice] = grouped
            .map { (category, accs) in
                let total = accs.compactMap { acc in
                    acc.balances?.max(by: { $0.date < $1.date })?.balance
                }.reduce(0.0, +)
                return Slice(category: category, total: total)
            }
            .filter { $0.total != 0 }
            .sorted { $0.category.rawValue < $1.category.rawValue }
        let total = repo.balance(for: accounts)

        VStack(alignment: .leading, spacing: 8) {
            if slices.isEmpty || total <= 0 {
                ContentUnavailableView(
                    "No data",
                    systemImage: "chart.pie.fill",
                    description: Text("Add balances to see distribution")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ZStack(alignment: .center)  {
                    Chart(slices.filter { $0.category != .loan }) { slice in
                        SectorMark(
                            angle: .value("Total", total),
                            innerRadius: .ratio(0.6),
                            angularInset: 1.0
                        )
                        // Use a String (Plottable) for grouping
                        .foregroundStyle(by: .value("Category", slice.category.localizedCategory))
                    }
                    .chartForegroundStyleScale(
                        domain: Category.allCases.map { $0.localizedCategory },
                        range: Category.allCases.map { $0.color }
                    )
                    .frame(height: 260)
                    .chartLegend(position: .bottom, spacing: 30)
                    // Center label (total)
                    VStack(alignment: .center, spacing: 10) {
                        Text("Total")
                            .font(.caption)
                        Text(total.toString)
                            .font(.headline)
                            .bold()
                            .minimumScaleFactor(0.5)
                            .frame(maxWidth: 100)
                            .multilineTextAlignment(.center)
                    }
                    .foregroundStyle(Color.patfiText)
                    .padding(.top, -60)
                }
                .padding(.top, -100)
            }
        }
        .padding()
    }

    private struct Slice: Identifiable {
        let category: Category
        let total: Double
        var id: String { category.rawValue }
    }
}

#Preview {
    DashboardPieChartView()
        .modelContainer(for: [Account.self, BalanceSnapshot.self], inMemory: true)
}

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
        let total = repo.totalBalance(accounts: accounts)

        VStack(alignment: .leading, spacing: 8) {
            if slices.isEmpty || total <= 0 {
                ContentUnavailableView(
                    "No data",
                    systemImage: "chart.pie.fill",
                    description: Text("Add balances to see distribution")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ZStack {
                    Chart(slices.filter { $0.category != .loan }) { slice in
                        SectorMark(
                            angle: .value("Total", slice.total)
                        )
                        // Use a String (Plottable) for grouping
                        .foregroundStyle(by: .value("Category", slice.category.localizedCategory))
                    }
                    .chartForegroundStyleScale(
                        domain: Category.allCases.map { $0.localizedCategory },
                        range: Category.allCases.map { $0.color }
                    )
                    .chartLegend(position: .automatic)
                    .frame(height: 240)

                    // Center label (total)
                    VStack(spacing: 2) {
                        Text(total.toString)
                            .font(.headline)
                            .monospacedDigit()
                            .foregroundStyle(.black)
                    }
                }
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

import SwiftUI
import SwiftData
import Charts

struct DashboardPieChartView: View {
    @Query(sort: [SortDescriptor(\Account.name, order: .forward)])
    private var accounts: [Account]

    var body: some View {
        let slices = computeSlices(accounts: accounts)
        let total = slices.reduce(0.0) { $0 + $1.total }

        VStack(alignment: .leading, spacing: 8) {
            if slices.isEmpty || total <= 0 {
                ContentUnavailableView(
                    "No data",
                    systemImage: "chart.pie.fill",
                    description: Text("Add balances to see category distribution")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ZStack {
                    Chart(slices) { slice in
                        SectorMark(
                            angle: .value("Total", slice.total)
                        )
                        // Use a String (Plottable) for grouping
                        .foregroundStyle(by: .value("Category", localizedCategory(slice.category)))
                    }
                    .chartForegroundStyleScale(
                        domain: Category.allCases.map { localizedCategory($0) },
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

    // MARK: - Computation
    private func computeSlices(accounts: [Account]) -> [Slice] {
        // Latest balance per account
        var latestByAccount: [Account: Double] = [:]
        for acc in accounts {
            if let snap = acc.balances?.max(by: { $0.date < $1.date }) {
                latestByAccount[acc] = snap.balance
            }
        }
        if latestByAccount.isEmpty { return [] }

        // Aggregate by category; clamp negatives to 0 to avoid invalid pie sectors
        var byCategory: [Category: Double] = [:]
        for (acc, value) in latestByAccount {
            let v = max(0, value)
            byCategory[acc.category, default: 0] += v
        }

        return byCategory
            .filter { $0.value > 0 }
            .sorted { $0.key.rawValue < $1.key.rawValue }
            .map { Slice(category: $0.key, total: $0.value) }
    }

    private func localizedCategory(_ c: Category) -> String {
        // Convert LocalizedStringResource to a concrete String for use in Charts (Plottable)
        String(localized: c.localizedName)
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

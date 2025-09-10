import SwiftUI
import SwiftData
import Charts

/// Super basic chart for dashboard: last 6 months total, no segmented control, no axis/grid.
struct DashboardTotalChartView: View {
    @Query(sort: [SortDescriptor(\BalanceSnapshot.date, order: .forward)])
    private var snapshots: [BalanceSnapshot]

    var body: some View {
        let base = computeTotalSeries(snapshots: snapshots)
        let series = filterLastSixMonths(base)

        Chart(series) { point in
            AreaMark(
                x: .value("Date", point.date),
                y: .value("Total", point.total)
            )
            LineMark(
                x: .value("Date", point.date),
                y: .value("Total", point.total)
            )
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .frame(height: 180)
        .padding(.horizontal)
    }

    // MARK: - Series computation
    private func computeTotalSeries(snapshots: [BalanceSnapshot]) -> [TotalPoint] {
        let valid = snapshots.compactMap { snap -> (date: Date, accountID: PersistentIdentifier, value: Double)? in
            guard let acc = snap.account else { return nil }
            let day = Calendar.current.startOfDay(for: snap.date)
            return (day, acc.persistentModelID, snap.balance)
        }
        if valid.isEmpty { return [] }

        let dates = Array(Set(valid.map { $0.date })).sorted()
        var lastByAccount: [PersistentIdentifier: Double] = [:]
        var result: [TotalPoint] = []

        var snapsByDate: [Date: [(PersistentIdentifier, Double)]] = [:]
        for item in valid { snapsByDate[item.date, default: []].append((item.accountID, item.value)) }

        for d in dates {
            if let updates = snapsByDate[d] {
                for (accID, value) in updates { lastByAccount[accID] = value }
            }
            let total = lastByAccount.values.reduce(0, +)
            result.append(TotalPoint(date: d, total: total))
        }
        return result
    }

    private func filterLastSixMonths(_ series: [TotalPoint]) -> [TotalPoint] {
        guard let lastDate = series.last?.date else { return series }
        let cal = Calendar.current
        let start = cal.date(byAdding: .month, value: -5, to: startOfMonth(lastDate)) ?? lastDate
        return series.filter { $0.date >= start }
    }

    private func startOfMonth(_ date: Date) -> Date {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: date)
        return cal.date(from: comps) ?? cal.startOfDay(for: date)
    }

    struct TotalPoint: Identifiable {
        let date: Date
        let total: Double
        var id: Double { date.timeIntervalSince1970 }
    }
}

#Preview {
    DashboardTotalChartView()
        .modelContainer(for: [Account.self, BalanceSnapshot.self], inMemory: true)
}

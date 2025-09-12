import SwiftUI
import SwiftData
import Charts

struct DashboardTotalChartView: View {
    
    @Query(sort: [SortDescriptor(\BalanceSnapshot.date, order: .forward)])
    private var snapshots: [BalanceSnapshot]

    var body: some View {
        let series = computeTotalSeries(snapshots: snapshots)

        VStack(alignment: .leading, spacing: 12) {

            if series.isEmpty {
                ContentUnavailableView(
                    "No data",
                    systemImage: "chart.line.uptrend.xyaxis",
                    description: Text("Add balances to see the graph")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Chart(series) { point in
                    AreaMark(
                        x: .value("Date", point.date),
                        y: .value("Total", point.total)
                    )
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisTick()
                        if let v = value.as(Double.self) {
                            AxisValueLabel(v.toString)
                        }
                    }
                }
                .frame(height: 260)
            }
        }
        .padding()
    }

    // MARK: - Series computation
    private func computeTotalSeries(snapshots: [BalanceSnapshot]) -> [TotalPoint] {
        // Filter out snapshots without an account (cannot attribute last-known logic)
        let valid = snapshots.compactMap { snap -> (date: Date, accountID: PersistentIdentifier, value: Double)? in
            guard let acc = snap.account else { return nil }
            let day = Calendar.current.startOfDay(for: snap.date)
            return (day, acc.persistentModelID, snap.balance)
        }
        if valid.isEmpty { return [] }

        // Determine maxDate and oneMonthAgo
        guard let maxDate = valid.map({ $0.date }).max() else { return [] }
        guard let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: maxDate) else { return [] }

        // Split valid into historical (< oneMonthAgo) and recent (>= oneMonthAgo)
        let historical = valid.filter { $0.date < oneMonthAgo }
        let recent = valid.filter { $0.date >= oneMonthAgo }

        if recent.isEmpty { return [] }

        // Collect all account IDs from recent snapshots
        let allAccountIDs = Set(recent.map { $0.accountID })

        // Initialize lastByAccount with last known value from historical or 0 if none
        var lastByAccount: [PersistentIdentifier: Double] = [:]
        for accID in allAccountIDs {
            let historicalForAccount = historical.filter { $0.accountID == accID }
            if let lastHistorical = historicalForAccount.max(by: { $0.date < $1.date }) {
                lastByAccount[accID] = lastHistorical.value
            } else {
                lastByAccount[accID] = 0
            }
        }

        // Group recent snapshots by date (ascending)
        let dates = Array(Set(recent.map { $0.date })).sorted()

        // Pre-group recent snapshots by date for efficient updates
        var snapsByDate: [Date: [(PersistentIdentifier, Double)]] = [:]
        for item in recent { snapsByDate[item.date, default: []].append((item.accountID, item.value)) }

        var result: [TotalPoint] = []

        for d in dates {
            if let updates = snapsByDate[d] {
                for (accID, value) in updates { lastByAccount[accID] = value }
            }
            // Ensure every account has a value for this date, assign 0 if not previously seen
            for accID in allAccountIDs {
                if lastByAccount[accID] == nil {
                    lastByAccount[accID] = 0
                }
            }
            let total = lastByAccount.values.reduce(0, +)
            result.append(TotalPoint(date: d, total: total))
        }
        return result
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

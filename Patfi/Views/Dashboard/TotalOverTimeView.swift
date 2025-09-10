import SwiftUI
import SwiftData
import Charts

struct TotalOverTimeView: View {
    @Query(sort: [SortDescriptor(\BalanceSnapshot.date, order: .forward)])
    private var snapshots: [BalanceSnapshot]

    var body: some View {
        let series = computeTotalSeries(snapshots: snapshots)

        VStack(alignment: .leading, spacing: 12) {
            if let last = series.last {
                Text(formatCurrency(last.total))
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .monospacedDigit()
                Text("Total across time")
                    .foregroundStyle(.secondary)
            }

            if series.isEmpty {
                ContentUnavailableView(
                    "No data",
                    systemImage: "chart.line.uptrend.xyaxis",
                    description: Text("Add balances to see your total over time")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
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
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 6))
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisTick()
                        if let v = value.as(Double.self) {
                            AxisValueLabel(formatCurrency(v))
                        }
                    }
                }
                .frame(height: 260)
            }
        }
        .padding()
        .navigationTitle("Total over time")
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

        // Group by date (ascending)
        let dates = Array(Set(valid.map { $0.date })).sorted()

        // For each date, update last-known balance per account then compute total
        var lastByAccount: [PersistentIdentifier: Double] = [:]
        var result: [TotalPoint] = []

        // Pre-group snapshots by date for efficient updates
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

    // MARK: - Formatters & Types
    private func formatCurrency(_ value: Double) -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .currency
        nf.currencyCode = Locale.current.currency?.identifier ?? "EUR"
        nf.maximumFractionDigits = 2
        nf.minimumFractionDigits = 2
        return nf.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
    }

    struct TotalPoint: Identifiable {
        let date: Date
        let total: Double
        var id: Double { date.timeIntervalSince1970 }
    }
}

#Preview {
    TotalOverTimeView()
        .modelContainer(for: [Account.self, BalanceSnapshot.self], inMemory: true)
}

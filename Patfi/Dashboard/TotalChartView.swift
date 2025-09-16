import SwiftUI
import SwiftData
import Charts

struct TotalChartView: View {
    
    @Query(sort: [SortDescriptor(\BalanceSnapshot.date, order: .forward)])
    private var snapshots: [BalanceSnapshot]

    private enum Period: String, CaseIterable, Identifiable {
        case weeks, months, years, all
        var id: String { rawValue }
        var title: LocalizedStringResource {
            switch self {
            case .weeks: return "Weeks"
            case .months: return "Months"
            case .years: return "Years"
            case .all: return "All"
            }
        }
    }

    @State private var period: Period = .months

    var body: some View {
        let baseSeries = computeTotalSeries(snapshots: snapshots)
        let series = filterSeries(baseSeries, for: period)

        VStack(alignment: .leading, spacing: 12) {
            Picker("Range", selection: $period) {
                ForEach(Period.allCases) { p in
                    Text(p.title).tag(p)
                }
            }
            .pickerStyle(.segmented)

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
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 6)) { value in
                        AxisGridLine()
                        AxisTick()
                        if let d = value.as(Date.self) {
                            AxisValueLabel(formatAxisLabel(for: d))
                        }
                    }
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

    private func filterSeries(_ series: [TotalPoint], for period: Period) -> [TotalPoint] {
        guard !series.isEmpty else { return series }
        let cal = Calendar.current
        let now = Date()
        switch period {
        case .weeks:
            // Last 6 weeks
            guard let start = cal.date(byAdding: .weekOfYear, value: -5, to: startOfWeek(now)) else { return series }
            return series.filter { $0.date >= start }
        case .months:
            // Last 6 months
            guard let start = cal.date(byAdding: .month, value: -5, to: startOfMonth(now)) else { return series }
            return series.filter { $0.date >= start }
        case .years:
            // Last 6 years
            guard let start = cal.date(byAdding: .year, value: -5, to: startOfYear(now)) else { return series }
            return series.filter { $0.date >= start }
        case .all:
            return series
        }
    }

    private func formatAxisLabel(for date: Date) -> String {
        let cal = Calendar.current
        switch period {
        case .weeks:
            return String((cal.component(.weekOfYear, from: date)))
        case .months:
            return String(cal.component(.month, from: date))
        case .years, .all:
            return String(cal.component(.year, from: date))
        }
    }

    private func startOfWeek(_ date: Date) -> Date {
        let cal = Calendar.current
        if let start = cal.dateInterval(of: .weekOfYear, for: date)?.start { return start }
        return cal.startOfDay(for: date)
    }
    private func startOfMonth(_ date: Date) -> Date {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: date)
        return cal.date(from: comps) ?? cal.startOfDay(for: date)
    }
    private func startOfYear(_ date: Date) -> Date {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year], from: date)
        return cal.date(from: comps) ?? cal.startOfDay(for: date)
    }

    struct TotalPoint: Identifiable {
        let date: Date
        let total: Double
        var id: Double { date.timeIntervalSince1970 }
    }
}

#Preview {
    TotalChartView()
        .modelContainer(for: [Account.self, BalanceSnapshot.self], inMemory: true)
}

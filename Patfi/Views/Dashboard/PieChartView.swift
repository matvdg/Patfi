import SwiftUI
import SwiftData
import Charts

struct PieChartView: View {
    @Query(sort: [SortDescriptor(\Account.name, order: .forward)])
    private var accounts: [Account]

    private enum Grouping: String, CaseIterable, Identifiable {
        case categories, banks
        var id: String { rawValue }
        var title: LocalizedStringResource {
            switch self {
            case .categories: return "Categories"
            case .banks: return "Banks"
            }
        }
    }

    @State private var grouping: Grouping = .categories

    var body: some View {
        let slices = computeSlices(accounts: accounts, grouping: grouping)
        let total = slices.reduce(0.0) { $0 + $1.total }

        VStack(alignment: .leading, spacing: 12) {
            // Segmented control
            Picker("", selection: $grouping) {
                ForEach(Grouping.allCases) { g in
                    Text(g.title).tag(g)
                }
            }
            .pickerStyle(.segmented)

            if slices.isEmpty || total <= 0 {
                ContentUnavailableView(
                    "No data",
                    systemImage: "chart.pie.fill",
                    description: Text("Add balances to see distribution")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Summary list above the chart
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(slices) { s in
                        HStack(spacing: 12) {
                            Circle().fill(s.color).frame(width: 10, height: 10)
                            Text(s.label)
                            Spacer()
                            Text(s.total.toString).monospacedDigit()
                        }
                    }
                }

                ZStack {
                    Chart(slices) { slice in
                        SectorMark(
                            angle: .value("Total", slice.total)
                        )
                        // Group by a concrete String label (Plottable)
                        .foregroundStyle(by: .value("", slice.label))
                    }
                    // Map legend colors to the dynamic labels for the current grouping
                    .chartForegroundStyleScale(
                        domain: slices.map { $0.label },
                        range: slices.map { $0.color }
                    )
                    .chartLegend(position: .automatic)
                    .frame(height: 240)

                    // Center label (total)
                    VStack(spacing: 2) {
                        Text(total.toString)
                            .font(.headline)
                            .monospacedDigit()
                        Text(String(localized: "Total"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
    }

    // MARK: - Computation
    private func computeSlices(accounts: [Account], grouping: Grouping) -> [Slice] {
        // Latest balance per account
        var latestByAccount: [Account: Double] = [:]
        for acc in accounts {
            if let snap = acc.balances?.max(by: { $0.date < $1.date }) {
                latestByAccount[acc] = snap.balance
            }
        }
        if latestByAccount.isEmpty { return [] }

        switch grouping {
        case .categories:
            var byCategory: [Category: Double] = [:]
            for (acc, value) in latestByAccount {
                let v = max(0, value)
                byCategory[acc.category, default: 0] += v
            }
            return byCategory
                .filter { $0.value > 0 }
                .sorted { $0.key.rawValue < $1.key.rawValue }
                .map { cat, total in
                    Slice(label: localizedCategory(cat), color: cat.color, total: total)
                }

        case .banks:
            // Aggregate by Bank (optional). Use persistentModelID as key; group "No bank" separately.
            struct BankAgg { var name: String; var color: Color; var total: Double }
            var byBank: [PersistentIdentifier: BankAgg] = [:]
            var noBankTotal: Double = 0

            for (acc, value) in latestByAccount {
                let v = max(0, value)
                if let bank = acc.bank {
                    let id = bank.persistentModelID
                    var agg = byBank[id] ?? BankAgg(name: bank.name, color: bank.swiftUIColor, total: 0)
                    // Keep latest name/color in case of edits
                    agg.name = bank.name
                    agg.color = bank.swiftUIColor
                    agg.total += v
                    byBank[id] = agg
                } else {
                    noBankTotal += v
                }
            }

            var slices: [Slice] = byBank.values
                .filter { $0.total > 0 }
                .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
                .map { Slice(label: $0.name.isEmpty ? "—" : $0.name, color: $0.color, total: $0.total) }

            if noBankTotal > 0 {
                slices.append(Slice(label: String(localized: "No bank"), color: .gray, total: noBankTotal))
            }
            return slices
        }
    }

    private func localizedCategory(_ c: Category) -> String {
        // Convert LocalizedStringResource to a concrete String for use in Charts (Plottable)
        String(localized: c.localizedName)
    }

    // MARK: - Types
    private struct Slice: Identifiable {
        let label: String
        let color: Color
        let total: Double
        var id: String { label }
    }
}

#Preview {
    PieChartView()
        .modelContainer(for: [Account.self, BalanceSnapshot.self, Bank.self], inMemory: true)
}

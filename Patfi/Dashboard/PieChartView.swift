import SwiftUI
import SwiftData
import Charts

struct PieChartView: View {
    @Query(sort: [SortDescriptor(\Account.name, order: .forward)])
    private var accounts: [Account]

    private let repo = BalanceRepository()

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

    private var allSlices: [Slice] {
        switch grouping {
        case .categories:
            return repo.groupByCategory(accounts).map { cat, accounts in
                Slice(label: cat.localizedCategory, color: cat.color, total: repo.balance(for: accounts))
            }
        case .banks:
            return repo.groupByBank(accounts).map { bank, accounts in
                Slice(label: bank.name, color: bank.swiftUIColor, total: repo.balance(for: accounts))
            }
        }
    }

    var body: some View {
        let slices = allSlices.filter { grouping != .categories || $0.label != Category.loan.localizedCategory }
        let total = repo.balance(for: accounts)

        VStack(alignment: .leading, spacing: 20) {
            // Segmented control
            Picker("", selection: $grouping) {
                ForEach(Grouping.allCases) { g in
                    Text(g.title).tag(g)
                }
            }
            .pickerStyle(.segmented)

            Spacer()
            
            if slices.isEmpty || total <= 0 {
                ContentUnavailableView(
                    "No data",
                    systemImage: "chart.pie.fill",
                    description: Text("Add balances to see distribution")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ZStack {
                    Chart(slices) { slice in
                        SectorMark(
                            angle: .value("Total", slice.total),
                            innerRadius: .ratio(0.6),
                            angularInset: 1.0
                        )
                        // Group by a concrete String label (Plottable)
                        .foregroundStyle(by: .value("", slice.label))
                    }
                    // Map legend colors to the dynamic labels for the current grouping
                    .chartForegroundStyleScale(
                        domain: slices.map { $0.label },
                        range: slices.map { $0.color }
                    )
                    .chartLegend(.hidden)
                    .frame(height: 240)

                    // Center label (total)
                    VStack {
                        Text("Total")
                            .font(.caption)
                        Text(total.toString)
                            .font(.headline)
                            .bold()
                            .minimumScaleFactor(0.5)
                            .frame(maxWidth: 100)
                            .multilineTextAlignment(.center)
                    }
                }
                
                Spacer()
                
                // Summary list below the chart
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(allSlices) { s in
                        HStack(spacing: 12) {
                            Circle().fill(s.color).frame(width: 10, height: 10)
                            Text(s.label)
                            Spacer()
                            Text(s.total.toString).monospacedDigit()
                        }
                    }
                }

                Spacer()
                
            }
        }
        .padding()
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

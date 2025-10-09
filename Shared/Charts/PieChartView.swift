import SwiftUI
import SwiftData
import Charts

struct PieChartView: View {
    @Query(sort: [SortDescriptor(\Account.name, order: .forward)])
    private var accounts: [Account]
    
    private let balanceRepository = BalanceRepository()
    
    @Binding var grouping: Mode
    
    private var allSlices: [Slice] {
        switch grouping {
        case .categories:
            return balanceRepository.groupByCategory(accounts)
                .map { cat, accounts in
                    Slice(label: cat.localized, color: cat.color, total: balanceRepository.balance(for: accounts))
                }
                .sorted {
                    $0.total > $1.total
                }
        case .banks:
            return balanceRepository.groupByBank(accounts)
                .map { bank, accounts in
                    Slice(label: bank.name, color: bank.swiftUIColor, total: balanceRepository.balance(for: accounts))
                }
                .sorted {
                    $0.total > $1.total
                }
        }
    }
    
    var body: some View {
        let slices = allSlices.filter { grouping != .categories || $0.label != Category.loan.localized }
        let total = balanceRepository.balance(for: accounts)
        
        VStack(alignment: .center, spacing: 20) {
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
                        .frame(maxWidth: 90)
                        .multilineTextAlignment(.center)
                }
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
    PieChartView(grouping: .constant(.banks))
        .modelContainer(ModelContainer.getSharedContainer())
}


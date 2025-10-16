import SwiftUI
import SwiftData
import Charts

struct PieChartView: View {
    
    @Query(sort: [SortDescriptor(\Account.name, order: .forward)])
    private var accounts: [Account]
        
    @Query(
        sort: [SortDescriptor(\Transaction.date, order: .reverse)]
    )
    private var transactions: [Transaction]
    
    private let balanceRepository = BalanceRepository()
    private let transactionRepository = TransactionRepository()
    
    @Binding var grouping: Mode
    
    private var allSlices: [Slice] {
        switch grouping {
        case .expenses: // TODO
            return transactionRepository.groupByCategory(transactions)
                .map { cat, accounts in
                    Slice(label: cat.localized, color: cat.color, total: transactionRepository.total(for: transactions))
                }
                .sorted {
                    $0.total > $1.total
                }
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
                        angle: .value("total", slice.total),
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
                    Text("total")
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
        .modelContainer(ModelContainer.shared)
}

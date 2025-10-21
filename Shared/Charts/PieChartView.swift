import SwiftUI
import SwiftData
import Charts

struct PieChartView: View {
    
    let accounts: [Account]
    let transactions: [Transaction]
    
    private let balanceRepository = BalanceRepository()
    private let accountRepository = AccountRepository()
    private let transactionRepository = TransactionRepository()
    
    var grouping: Mode
    var sortByPaymentMethod: Bool? = nil
    var sortByBank: Bool? = nil
    
    private var allSlices: [Slice] {
        switch grouping {
        case .expenses:
            if let sortByPaymentMethod, sortByPaymentMethod {
                return transactionRepository.groupByPaymentMethod(transactions)
                    .map { paymentMethod, transactions in
                        Slice(label: paymentMethod.localized, color: paymentMethod.color, total: transactionRepository.total(for: transactions))
                    }
                    .sorted {
                        $0.total > $1.total
                    }
            } else {
                return transactionRepository.groupByCategory(transactions)
                    .map { cat, transactions in
                        Slice(label: cat.localized, color: cat.color, total: transactionRepository.total(for: transactions))
                    }
                    .sorted {
                        $0.total > $1.total
                    }
            }
        case .accounts:
            if let sortByBank, sortByBank {
                return accountRepository.groupByBank(accounts)
                    .map { bank, accounts in
                        Slice(label: bank.name, color: bank.swiftUIColor, total: balanceRepository.balance(for: accounts))
                    }
                    .sorted {
                        $0.total > $1.total
                    }
            } else {
                return accountRepository.groupByCategory(accounts)
                    .map { cat, accounts in
                        Slice(label: cat.localized, color: cat.color, total: balanceRepository.balance(for: accounts))
                    }
                    .sorted {
                        $0.total > $1.total
                    }
            }
        }
    }
    
    var body: some View {
        let slices = allSlices.filter { sortByBank == nil || $0.total > 0 }
        let total: Double = grouping == .expenses ? transactionRepository.total(for: transactions) : balanceRepository.balance(for: accounts)
        
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
    PieChartView(accounts: [], transactions: [Transaction(title: "Carrefour", transactionType: .expense, paymentMethod: .applePay, expenseCategory: .foodGroceries, date: Date(), amount: 130.00, account: nil, isInternalTransfer: false), Transaction(title: "Travel", transactionType: .expense, paymentMethod: .creditCard, expenseCategory: .travel, date: Date(), amount: 1300.00, account: nil, isInternalTransfer: false), Transaction(title: "Transport", transactionType: .expense, paymentMethod: .directDebit, expenseCategory: .transportation, date: Date(), amount: 544, account: nil, isInternalTransfer: false)], grouping: .accounts)
}

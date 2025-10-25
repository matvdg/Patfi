import SwiftData
import SwiftUI

struct ExpensesView: View {
    
    init(selectedMonth: Date, sortByPaymentMethod: Bool) {
        self.selectedMonth = selectedMonth
        self.sortByPaymentMethod = sortByPaymentMethod
        _transactions = Query(filter: Transaction.predicate(for: .months, containing: selectedMonth), sort: \.date, order: .reverse)
    }
    
    var selectedMonth: Date
    var sortByPaymentMethod: Bool
    
    @Query private var transactions: [Transaction]
    @Environment(\.modelContext) private var context
    
    private let transactionRepository = TransactionRepository()
    
    private var expenses: [Transaction] {
        transactions.filter { $0.expenseCategory != nil }
    }
    
    private var expensesByCategory: [TransactionsPerCategory.Element] {
        Array(transactionRepository.groupByCategory(expenses))
            .sorted {
                transactionRepository.total(for: $0.value) > transactionRepository.total(for: $1.value)
            }
    }
    
    private var expensesByPaymentMethod: [TransactionsPerPaymentMethod.Element] {
        Array(transactionRepository.groupByPaymentMethod(expenses))
            .sorted {
                transactionRepository.total(for: $0.value) > transactionRepository.total(for: $1.value)
            }
    }
    
    var body: some View {
        if transactions.isEmpty {
            ContentUnavailableView(
                "noData",
                systemImage: "receipt",
                description: Text("transactionsEmptyDescription")
            )
        } else {
            VStack {
                PieChartView(accounts: [], transactions: expenses, grouping: .expenses, sortByPaymentMethod: sortByPaymentMethod)
                if sortByPaymentMethod {
                    ForEach(expensesByPaymentMethod, id: \.key) { (paymentMethod, expenses) in
                        HStack(spacing: 8) {
                            Circle().fill(paymentMethod.color).frame(width: 10, height: 10)
                            Text(paymentMethod.localized).lineLimit(1)
                            Spacer()
                            AmountText(amount: -transactionRepository.total(for: expenses))
                        }
                        .minimumScaleFactor(0.2)
                        .font(.footnote)
                    }
                } else {
                    ForEach(expensesByCategory, id: \.key) { (cat, expenses) in
                        HStack(spacing: 8) {
                            Circle().fill(cat.color).frame(width: 10, height: 10)
                            Text(cat.localized)
                            Spacer()
                            AmountText(amount: -transactionRepository.total(for: expenses))
                        }
                        .minimumScaleFactor(0.2)
                        .font(.footnote)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        List {
            ExpensesView(selectedMonth: Date(), sortByPaymentMethod: false)
                .modelContainer(ModelContainer.shared)
        }
    }
}

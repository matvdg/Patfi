import SwiftData
import SwiftUI

struct TransactionsView: View {
    
    private var selectedMonth: Date
    
    @Query private var transactions: [Transaction]
    @Environment(\.modelContext) private var context
    @State private var hideInternalTransfers = false

    private let transactionRepository = TransactionRepository()

    init(month: Date) {
        self.selectedMonth = month
        _transactions = Query(filter: Transaction.predicate(forMonth: month), sort: \.date, order: .reverse)
    }
    
    private var filteredTransactions: [Transaction] {
        if hideInternalTransfers {
            return transactions.filter { !$0.isInternalTransfer }
        } else {
            return transactions
        }
    }

    var body: some View {
        VStack {
            Toggle("hideInternalTransfers", isOn: $hideInternalTransfers)
                    .padding(.horizontal)
            List(filteredTransactions) { transaction in
                NavigationLink {
                    EditTransactionView(transaction: transaction)
                } label: {
                    TransactionRow(transaction: transaction)
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        transactionRepository.delete(transaction, context: context)
                    } label: { Label("delete", systemImage: "trash") }
                }
#if !os(watchOS)
                .contextMenu {
                    Button(role: .destructive) {
                        transactionRepository.delete(transaction, context: context)
                    } label: {
                        Label("delete", systemImage: "trash")
                    }
                }
#endif
            }
        }
        .navigationTitle("transactions")
    }
}

struct FilteredTransactionsView: View {
    
    @State private var selectedMonth: Date = .now
    
    var body: some View {
        VStack {
            MonthPicker(selectedMonth: $selectedMonth)
            TransactionsView(month: selectedMonth)
        }
    }
}

#Preview {
    NavigationStack {
        FilteredTransactionsView()
            .modelContainer(ModelContainer.shared)
    }
}

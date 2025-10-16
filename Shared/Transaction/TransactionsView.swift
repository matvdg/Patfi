import SwiftData
import SwiftUI

struct TransactionsView: View {
    
    private var selectedMonth: Date
    private var hideInternalTransfers: Bool
    @Query private var transactions: [Transaction]
    @Environment(\.modelContext) private var context

    private let transactionRepository = TransactionRepository()

    init(month: Date, hideInternalTransfers: Bool) {
        self.selectedMonth = month
        self.hideInternalTransfers = hideInternalTransfers
//        _transactions = Query(filter: Transaction.predicate(forMonth: month, hideInternalTransfers: hideInternalTransfers), sort: \.date, order: .reverse)
    }

    var body: some View {
        VStack {
            List(transactions) { transaction in
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
        .navigationTitle(Text(selectedMonth, format: Date.FormatStyle().month().year()))
        .onChange(of: transactions) { old, new in
            print(old.count, new.count)
        }
    }
}

#Preview {
    NavigationStack {
        TransactionsView(month: Date(), hideInternalTransfers: true)
            .modelContainer(ModelContainer.shared)
    }
}

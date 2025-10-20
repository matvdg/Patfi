import SwiftData
import SwiftUI

struct HomeTransactionsView: View {
    
    @State private var selectedDate: Date = .now
    @State private var period: Period = .months
    
    var body: some View {
        VStack {
            PeriodPicker(selectedDate: $selectedDate, period: $period)
            TransactionsView(for: period, containing: selectedDate)
        }
    }
}

struct TransactionsView: View {
    
    private var selectedDate: Date
    private var period: Period
    
    @Query private var transactions: [Transaction]
    @Environment(\.modelContext) private var context
    @State private var hideInternalTransfers = false

    private let transactionRepository = TransactionRepository()

    init(for period: Period, containing selectedDate: Date) {
        self.selectedDate = selectedDate
        self.period = period
        _transactions = Query(filter: Transaction.predicate(for: period, containing: selectedDate), sort: \.date, order: .reverse)
    }
    
    private var filteredTransactions: [Transaction] {
        if hideInternalTransfers {
            return transactions.filter { !$0.isInternalTransfer }
        } else {
            return transactions
        }
    }

    var body: some View {
        Group {
            if transactions.isEmpty {
                ContentUnavailableView(
                    "noData",
                    systemImage: "receipt",
                    description: Text("transactionsEmptyDescription")
                )
            } else {
                VStack {
                    Toggle("hideInternalTransfers", isOn: $hideInternalTransfers)
                        .padding(.horizontal)
                    TransactionChartView(transactions: filteredTransactions)
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
            }
        }
        .navigationTitle("transactions")
    }
}

#Preview {
    NavigationStack {
        HomeTransactionsView()
            .modelContainer(ModelContainer.shared)
    }
}

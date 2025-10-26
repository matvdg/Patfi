import SwiftData
import SwiftUI

struct HomeTransactionsView: View {
    
    @State private var selectedDate: Date = .now
    @State private var selectedPeriod: Period = .month
    
    var body: some View {
        VStack {
            PeriodPicker(selectedDate: $selectedDate, selectedPeriod: $selectedPeriod)
            TransactionsView(for: selectedPeriod, containing: selectedDate)
        }
    }
}

struct TransactionsView: View {
    
    private var selectedDate: Date
    private var selectedPeriod: Period
    
    @Query private var transactions: [Transaction]
    @Environment(\.modelContext) private var context
    @State private var hideInternalTransfers = false

    private let transactionRepository = TransactionRepository()

    init(for selectedPeriod: Period, containing selectedDate: Date) {
        self.selectedDate = selectedDate
        self.selectedPeriod = selectedPeriod
        _transactions = Query(filter: Transaction.predicate(for: selectedPeriod, containing: selectedDate), sort: \.date, order: .reverse)
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
                VStack {
                    ContentUnavailableView(
                        "NoData",
                        systemImage: "receipt",
                        description: Text("DescriptionEmptyTransactions")
                    )
                    Spacer()
                }
            } else {
                VStack {
                    Toggle("HideInternalTransfers", isOn: $hideInternalTransfers)
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
                            } label: { Label("Delete", systemImage: "trash") }
                        }
#if !os(watchOS)
                        .contextMenu {
                            Button(role: .destructive) {
                                transactionRepository.delete(transaction, context: context)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
#endif
                    }
                }
            }
        }
        .navigationTitle("Transactions")
    }
}

#Preview {
    NavigationStack {
        HomeTransactionsView()
            .modelContainer(ModelContainer.shared)
    }
}

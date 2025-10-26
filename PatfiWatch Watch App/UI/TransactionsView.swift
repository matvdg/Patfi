import SwiftData
import SwiftUI

struct TransactionsView: View {
    
    @State private var selectedDate: Date = .now
    @State private var selectedPeriod: Period = .month
    @State private var showActions = false
    @Query(sort: \Account.name, order: .forward) private var accounts: [Account]
    
    var body: some View {
        VStack {
            PeriodPicker(selectedDate: $selectedDate, selectedPeriod: $selectedPeriod)
            FilteredTransactionsView(selectedDate: selectedDate, selectedPeriod: selectedPeriod)
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    showActions = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .confirmationDialog("Add", isPresented: $showActions) {
            ForEach(QuickAction.allCases, id: \.self) { action in
                // If there are no accounts, skip actions that require an account
                if accounts.isEmpty && action.requiresAccount {
                    // Skip
                } else {
                    NavigationLink(action.localizedTitle) {
                        action.destinationView()
                    }
                }
            }
        }
    }
}

struct FilteredTransactionsView: View {
    
    private var selectedDate: Date
    private var selectedPeriod: Period
    
    @Query private var transactions: [Transaction]
    @Environment(\.modelContext) private var context
    @State private var hideInternalTransfers = false
    
    private let transactionRepository = TransactionRepository()
    
    init(selectedDate: Date, selectedPeriod: Period) {
        self.selectedDate = selectedDate
        self.selectedPeriod = selectedPeriod
        _transactions = Query(filter: Transaction.predicate(for: selectedPeriod, containing: selectedDate), sort: \.date, order: .reverse)
    }
    
    var body: some View {
        Group {
            if transactions.isEmpty {
                ContentUnavailableView(
                    "NoData",
                    systemImage: "receipt",
                    description: Text("DescriptionEmptyTransactions")
                )
            } else {
                List(transactions) { transaction in
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
                }
            }
        }
        .navigationTitle("Transactions")
    }
}

#Preview {
    NavigationStack {
        TransactionsView()
            .modelContainer(ModelContainer.shared)
    }
}

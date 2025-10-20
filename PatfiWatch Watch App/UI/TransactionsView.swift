import SwiftData
import SwiftUI

struct FilteredTransactionsView: View {
    
    @State private var selectedMonth: Date = .now
    @State private var showActions = false
    @Query(sort: \Account.name, order: .forward) private var accounts: [Account]
    
    var body: some View {
        VStack {
            PeriodPicker(selectedDate: $selectedMonth, period: .constant(.months))
            TransactionsView(month: selectedMonth)
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
        .confirmationDialog("add", isPresented: $showActions) {
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

struct TransactionsView: View {
    
    private var selectedMonth: Date
    
    @Query private var transactions: [Transaction]
    @Environment(\.modelContext) private var context
    @State private var hideInternalTransfers = false
    
    private let transactionRepository = TransactionRepository()
    
    init(month: Date) {
        self.selectedMonth = month
        _transactions = Query(filter: Transaction.predicate(for: .months, containing: selectedMonth), sort: \.date, order: .reverse)
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
                }
            }
        }
        .navigationTitle("transactions")
    }
}

#Preview {
    NavigationStack {
        FilteredTransactionsView()
            .modelContainer(ModelContainer.shared)
    }
}

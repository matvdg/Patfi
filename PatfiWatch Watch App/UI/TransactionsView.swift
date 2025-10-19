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
    
    var body: some View {
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
        .navigationTitle("transactions")
        
    }
}

struct FilteredTransactionsView: View {
    
    @State private var selectedMonth: Date = .now
    @State private var showActions = false
    @Query(sort: \Account.name, order: .forward) private var accounts: [Account]

    var body: some View {
        VStack {
            MonthPicker(selectedMonth: $selectedMonth)
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

#Preview {
    NavigationStack {
        FilteredTransactionsView()
            .modelContainer(ModelContainer.shared)
    }
}

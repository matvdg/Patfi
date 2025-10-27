import SwiftData
import SwiftUI

struct HomeTransactionsView: View {
    
    @State private var selectedDate: Date = .now
    @State private var selectedPeriod: Period = .month
    @State private var showActions: Bool = false
    
    private var account: Account?
    
    init(account: Account? = nil) {
        self.account = account
    }
    
    var body: some View {
        VStack {
            PeriodPicker(selectedDate: $selectedDate, selectedPeriod: $selectedPeriod)
            TransactionsView(for: selectedPeriod, containing: selectedDate, account: account)
        }
#if os(watchOS)
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
                NavigationLink(action.localizedTitle) {
                    action.destinationView()
                }
            }
        }
#endif
    }
}

struct TransactionsView: View {
    
    private var selectedDate: Date
    private var selectedPeriod: Period
    private var account: Account?
    
    @Query private var transactions: [Transaction]
    @Environment(\.modelContext) private var context
    @State private var hideInternalTransfers = false
    
    private let transactionRepository = TransactionRepository()
    
    init(for selectedPeriod: Period, containing selectedDate: Date, account: Account?) {
        self.selectedDate = selectedDate
        self.selectedPeriod = selectedPeriod
        self.account = account
        _transactions = Query(filter: Transaction.predicate(for: selectedPeriod, containing: selectedDate), sort: \.date, order: .reverse)
    }
    
    private var accountTransactions: [Transaction] {
        var accountTransactions: [Transaction] = transactions
        if let account {
            accountTransactions = transactions.filter { $0.account?.id == account.id }
        }
        return accountTransactions
    }
    
    private var filteredTransactions: [Transaction] {
        var filteredTransactions: [Transaction] = accountTransactions
        if hideInternalTransfers {
            filteredTransactions = accountTransactions.filter { !$0.isInternalTransfer }
        }
        return filteredTransactions
    }
    
    var body: some View {
        Group {
            if accountTransactions.isEmpty {
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
#if !os(watchOS)
                    Toggle("HideInternalTransfers", isOn: $hideInternalTransfers)
                        .padding(.horizontal)
                    TransactionChartView(transactions: filteredTransactions)
#endif
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

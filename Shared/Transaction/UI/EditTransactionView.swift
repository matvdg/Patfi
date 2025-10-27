import SwiftUI
import SwiftData

struct EditTransactionView: View {
    
    @Bindable var transaction: Transaction
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @FocusState private var focused: Bool
    
    let transactionRepository =  TransactionRepository()
    
    var body: some View {
        
        Form {
            Section {
                HStack {
                    Text("Amount")
                    Spacer()
                    Text(transaction.transactionType == .income ? "+\(transaction.amount.currencyAmount)" : "-\(transaction.amount.currencyAmount)")
                        .font(.body)
                        .bold()
                        .foregroundColor(transaction.transactionType == .expense ? .red : .green)
                }
                if let account = transaction.account {
                    HStack {
                        Text("Account")
                        Spacer()
                        AccountRow(account: account, displayBalance: false)
                    }
                }
            }
            Section {
                TextField("Description", text: $transaction.title)
#if !os(macOS)
                    .textInputAutocapitalization(.words)
#endif
                    .autocorrectionDisabled()
                
                if !transaction.isInternalTransfer {
                    PaymentMethodPicker(paymentMethod: $transaction.paymentMethod)
                }
                
                if transaction.transactionType == .expense {
                    if transaction.isInternalTransfer {
                        Toggle("MarkAsSavingsOrInvestment", isOn: Binding(
                            get: { transaction.expenseCategory == .savingsInvestments },
                            set: { transaction.expenseCategory = $0 ? .savingsInvestments : nil }
                        ))
                    } else {
                        ExpenseCategoryPicker(expenseCategory: $transaction.expenseCategory)
                    }
                }
                DatePicker("Date", selection: $transaction.date, displayedComponents: [.date])
                Button(role: .destructive) {
                    transactionRepository.delete(transaction, context: context)
                    dismiss()
                }.foregroundStyle(.red)
            } header: {
                Text("Edit")
            }
            
        }
        .navigationTitle(transaction.isInternalTransfer ? "InternalTransfer" : transaction.transactionType == .expense ? "Expense" : "Income")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(role: .confirm, action: {
                    dismiss()
                })
                .disabled(transaction.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { focused = true } }
        .formStyle(.grouped)
        
    }
}

#Preview {
    TabView {
        NavigationStack{
            EditTransactionView(transaction: Transaction(title: "Internal transfer", transactionType: .expense, paymentMethod: .bankTransfer, expenseCategory: nil, date: Date(), amount: 2000, account: Account(name: "CAV", category: .current, bank: Bank(name: "CIC", color: .green, logoAvaibility: .available)), isInternalTransfer: true))
        }
        NavigationStack{
            EditTransactionView(transaction: Transaction(title: "Internal transfer", transactionType: .income, paymentMethod: .bankTransfer, expenseCategory: nil, date: Date(), amount: 2000, account: Account(name: "CAV", category: .current, bank: Bank(name: "CIC", color: .green, logoAvaibility: .available)), isInternalTransfer: true))
        }
        NavigationStack{
            EditTransactionView(transaction: Transaction(title: "Carrefour", transactionType: .expense, paymentMethod: .creditCard, expenseCategory: .foodGroceries, date: Date(), amount: 123, account: Account(name: "CAV", category: .current, bank: Bank(name: "CIC", color: .green, logoAvaibility: .available)), isInternalTransfer: false))
        }
        NavigationStack{
            EditTransactionView(transaction: Transaction(title: "Wage", transactionType: .income, paymentMethod: .bankTransfer, expenseCategory: nil, date: Date(), amount: 2000, account: Account(name: "CAV", category: .current, bank: Bank(name: "CIC", color: .green, logoAvaibility: .available)), isInternalTransfer: false))
        }
    }
#if !os(macOS)
    .tabViewStyle(.page)
#endif
    .ignoresSafeArea()
    .modelContainer(ModelContainer.shared)
}

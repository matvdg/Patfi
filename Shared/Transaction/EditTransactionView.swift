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
                TransactionRow(transaction: transaction, onlyAmount: true)
                if let account = transaction.account {
                    HStack {
                        Text("account")
                        Spacer()
                        AccountRow(account: account, displayBalance: false)
                    }
                }
                TextField("description", text: $transaction.title)
#if !os(macOS)
                    .textInputAutocapitalization(.words)
#endif
                    .autocorrectionDisabled()

                PaymentMethodPicker(paymentMethod: $transaction.paymentMethod)
                if transaction.transactionType == .expense {
                    ExpenseCategoryPicker(expenseCategory: $transaction.expenseCategory)
                }
                DatePicker("date", selection: $transaction.date, displayedComponents: [.date])
                Button(role: .destructive) {
                    transactionRepository.delete(transaction, context: context)
                    dismiss()
                }.foregroundStyle(.red)
            } footer: {
                if transaction.isInternalTransfer {
                    Text("internalTransfer")
                }
            }
        }
        .navigationTitle("edit")
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
    NavigationStack{
        EditTransactionView(transaction: Transaction(title: "Carrefour", transactionType: .expense, paymentMethod: .creditCard, expenseCategory: .foodGroceries, date: Date(), amount: 123, account: Account(name: "CAV", category: .current, bank: Bank(name: "CIC", color: .green, logoAvaibility: .available)), isInternalTransfer: false))
//        EditTransactionView(transaction: Transaction(title: "Wage", transactionType: .income, paymentMethod: .bankTransfer, expenseCategory: nil, date: Date(), amount: 2000, account: Account(name: "CAV", category: .current, bank: Bank(name: "CIC", color: .green, logoAvaibility: .available)), isInternalTransfer: false))
    }
    .modelContainer(ModelContainer.shared)
}

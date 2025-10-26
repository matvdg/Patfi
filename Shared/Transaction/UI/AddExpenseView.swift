import SwiftUI
import SwiftData

struct AddExpenseView: View {
    
    init(account: Account? = nil) {
        _selectedAccountID = State(initialValue: account?.persistentModelID)
    }
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @Query(sort: \Account.name, order: .forward) private var accounts: [Account]
    
    @State private var title: String = ""
    @State private var paymentMethod: Transaction.PaymentMethod = .applePay
    @State private var expenseCategory: Transaction.ExpenseCategory?
    @State private var amount: Double?
    @FocusState private var focused: Bool
    @State private var selectedAccountID: PersistentIdentifier?
    @State private var date: Date = .now
    
    private var selectedAccount: Account? {
        accounts.first(where: { $0.persistentModelID == selectedAccountID })
    }
    
    let transactionRepository =  TransactionRepository()
    
    var body: some View {
        Form {
            Section {
                AmountTextField(amount: $amount, signMode: .negativeOnly)
                    .focused($focused)
                TextField("Description", text: $title)
#if !os(macOS)
                    .textInputAutocapitalization(.words)
#endif
                    .autocorrectionDisabled()
                AccountPicker(id: $selectedAccountID, title: String(localized: "Account"))
                PaymentMethodPicker(paymentMethod: $paymentMethod)
                ExpenseCategoryPicker(expenseCategory: $expenseCategory)
                DatePicker("Date", selection: $date, displayedComponents: [.date])
            } footer: {
                if let account = selectedAccount, let balance = account.latestBalance?.balance {
                    HStack {
                        if let bank = account.bank {
                            Text(bank.name)
                            Text(" • ")
                        }
                        Text(account.name)
                        Text(" • ")
                        if let amount {
                            Text("PreviousBalance \(balance.currencyAmount) newBalance \((balance - abs(amount)).currencyAmount)")
                        } else {
                            Text("Balance: \(balance.currencyAmount)")
                        }
                    }
                }
            }
        }
        .navigationTitle("AddExpense")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(role: .confirm, action: {
                    guard let amount, let selectedAccount, let expenseCategory else { return }
                    transactionRepository.addExpense(title: title, amount: amount, account: selectedAccount, paymentMethod: paymentMethod, expenseCategory: expenseCategory, date: date, context: context)
                    dismiss()
                    
                })
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedAccount == nil || amount == nil || amount == 0 || expenseCategory == nil)
            }
        }
        .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { focused = true } }
        .formStyle(.grouped)
        .onChange(of: accounts, initial: true) { _, newAccounts in
            if selectedAccountID == nil,
               let defaultAccount = newAccounts.first(where: { $0.isDefault }) {
                selectedAccountID = defaultAccount.persistentModelID
            }
        }
    }
}

struct PaymentMethodPicker: View {
    
    @Binding var paymentMethod: Transaction.PaymentMethod
    
    var body: some View {
        
        Picker("PaymentMethod", selection: $paymentMethod) {
            ForEach(Transaction.PaymentMethod.allCases) { p in
                Label(p.localized, systemImage: p.iconName)
                    .foregroundStyle(.primary)
                    .tag(p)
            }
        }
#if !os(macOS)
        .pickerStyle(.navigationLink)
#endif
        .foregroundStyle(.primary)
    }
}


struct ExpenseCategoryPicker: View {
    
    @Binding var expenseCategory: Transaction.ExpenseCategory?
    
    var body: some View {
        
        Picker("ExpenseCategory", selection: $expenseCategory) {
            ForEach(Transaction.ExpenseCategory.allCases) { cat in
                Label(cat.localized, systemImage: cat.iconName)
                    .foregroundStyle(.primary)
                    .tag(cat)
            }
        }
#if !os(macOS)
        .pickerStyle(.navigationLink)
#endif
        .foregroundStyle(.primary)
    }
}

#Preview {
    NavigationStack{
        AddExpenseView()
    }
    .modelContainer(ModelContainer.shared)
}

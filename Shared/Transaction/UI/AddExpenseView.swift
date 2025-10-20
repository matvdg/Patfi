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
    @State private var amountText: String = ""
    @FocusState private var focused: Bool
    @State private var selectedAccountID: PersistentIdentifier?
    @State private var date: Date = .now
    
    private var selectedAccount: Account? {
        accounts.first(where: { $0.persistentModelID == selectedAccountID })
    }
    
    let transactionRepository =  TransactionRepository()
    
    var amount: Double? {
        Double(amountText.replacingOccurrences(of: ",", with: "."))
    }
    
    var body: some View {
        Form {
            Section {
#if os(watchOS)
                NavigationLink {
                    NumericalKeyboardView(text: $amountText)
                } label: {
                    Text(amountText.isEmpty ? String(localized:"amount") : amountText)
                }
#else
                TextField("amount", text: $amountText)
#if os(iOS) || os(tvOS) || os(visionOS)
                    .keyboardType(.decimalPad)
#endif
                    .focused($focused)
                    .onChange(of: amountText) { _, newValue in
                        let cleaned = newValue.filter { !$0.isWhitespace }
                        if cleaned != newValue {
                            amountText = cleaned
                        }
                    }
#endif
                TextField("description", text: $title)
#if !os(macOS)
                    .textInputAutocapitalization(.words)
#endif
                    .autocorrectionDisabled()
                AccountPicker(id: $selectedAccountID, title: String(localized: "account"))
                PaymentMethodPicker(paymentMethod: $paymentMethod)
                ExpenseCategoryPicker(expenseCategory: $expenseCategory)
                DatePicker("date", selection: $date, displayedComponents: [.date])
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
                            Text("previousBalance \(balance.toString) newBalance \((balance - amount).toString)")
                        } else {
                            Text("balance: \(balance.toString)")
                        }
                    }
                }
            }
        }
        .navigationTitle("addExpense")
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
        
        Picker("paymentMethod", selection: $paymentMethod) {
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
        
        Picker("expenseCategory", selection: $expenseCategory) {
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

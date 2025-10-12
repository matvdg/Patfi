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

    private var selectedAccount: Account? {
        accounts.first(where: { $0.persistentModelID == selectedAccountID })
    }
    
    let transactionRepository =  TransactionRepository()
    
    var amount: Double? {
        Double(amountText.replacingOccurrences(of: ",", with: "."))
    }
    
    var body: some View {
        Form {
#if os(watchOS)
            NavigationLink {
                NumericalKeyboardView(text: $amountText)
            } label: {
                Text(amountText.isEmpty ? String(localized:"Amount") : amountText)
            }
#else
            TextField("Amount", text: $amountText)
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
            TextField("Name", text: $title)
#if !os(macOS)
                .textInputAutocapitalization(.words)
#endif
                .autocorrectionDisabled()
            HStack {
                Image(systemName: paymentMethod.iconName)
                Picker("PaymentMethod", selection: $paymentMethod) {
                    ForEach(Transaction.PaymentMethod.allCases) { p in
                        Text(p.localized)
                            .tag(p)
                    }
                }
            }
            HStack {
                if let bank = selectedAccount?.bank {
                    BankLogo(bank: bank)
                        .id(bank.id)
                }
                Picker("Account", selection: $selectedAccountID) {
                    ForEach(accounts) { acc in
                        if let name = acc.bank?.name {
                            Text("\(name ) • \(acc.name)")
                                .tag(acc.persistentModelID)
                        } else {
                            Text(acc.name)
                                .tag(acc.persistentModelID)
                        }
                    }
                }
            }
            HStack {
                if let icon = expenseCategory?.iconName {
                    Image(systemName: icon)
                }
                Picker("ExpenseCategory", selection: $expenseCategory) {
                    ForEach(Transaction.ExpenseCategory.allCases) { cat in
                        Text(cat.localized)
                            .tag(cat)
                    }
                }
            }
        }
        .navigationTitle("Add expense")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(role: .confirm, action: {
                    guard let amount, let selectedAccount, let expenseCategory else { return }
                    transactionRepository.addExpense(title: title, amount: amount, account: selectedAccount, paymentMethod: paymentMethod, expenseCategory: expenseCategory, context: context)
                    dismiss()
                    
                })
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedAccount == nil || amount == nil || expenseCategory == nil)
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

#Preview {
    NavigationStack{
        AddExpenseView()
    }
    .modelContainer(ModelContainer.shared)
}

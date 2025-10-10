import SwiftUI
import SwiftData

struct AddExpenseView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @Query(sort: \Account.name, order: .forward) private var accounts: [Account]
    
    @State private var title: String = ""
    @State private var paymentMethod: Transaction.PaymentMethod = .applePay
    @State private var expenseCategory: Transaction.ExpenseCategory?
    @State private var amountText: String = ""
    @State private var account: Account? = nil
    @FocusState private var focused: Bool
    
    let transactionRepository =  TransactionRepository()
    
    var amount: Double? {
        Double(amountText.replacingOccurrences(of: ",", with: "."))
    }
    
    var body: some View {
        Form {
            Section("Expense") {
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
                    .frame(maxWidth: 300)
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
                    .frame(maxWidth: 300)
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
                    if let bank = account?.bank {
                        BankLogo(bank: bank)
                    }
                    Picker("Account", selection: $account) {
                        ForEach(accounts) { account in
                            if let name = account.bank?.name {
                                Text("\(name ) • \(account.name)")
                                    .tag(account)
                            } else {
                                Text(account.name)
                                    .tag(account)
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
        }
        .navigationTitle("New expense")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(role: .confirm, action: {
                    guard let amount, let account, let expenseCategory else { return }
                    transactionRepository.addExpense(title: title, amount: amount, account: account, paymentMethod: paymentMethod, expenseCategory: expenseCategory, context: context)
                    dismiss()
                    
                })
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || account == nil || amount == nil || expenseCategory == nil)
            }
        }
        .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { focused = true } }
        .formStyle(.grouped)
    }
}

#Preview {
    NavigationStack{
        AddExpenseView()
    }
        .modelContainer(ModelContainer.getSharedContainer())
}

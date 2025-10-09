import SwiftUI
import SwiftData

struct AddExpenseView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @Query(sort: \Account.name, order: .forward) private var accounts: [Account]
    
    @State private var title: String = ""
    @State private var paymentMethod: Transaction.PaymentMethod = .applePay
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
            }
            
            Section("Amount") {
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
            }
        }
        .navigationTitle("New expense")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(role: .confirm, action: {
                    guard let amount, let account else { return }
                    transactionRepository.addExpense(title: title, amount: amount, account: account, paymentMethod: paymentMethod, context: context)
                    dismiss()
                    
                })
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || account == nil || amount == nil)
            }
        }
        .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { focused = true } }
        .formStyle(.grouped)
    }
}

#Preview {
    NavigationStack{AddExpenseView()}
        .modelContainer(ModelContainer.getSharedContainer())
}

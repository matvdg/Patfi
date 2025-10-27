import SwiftUI
import SwiftData

struct AddIncomeView: View {
    
    
    init(account: Account? = nil) {
        _selectedAccountID = State(initialValue: account?.persistentModelID)
    }
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @Query(sort: \Account.name, order: .forward) private var accounts: [Account]
    
    @State private var title: String = ""
    @State private var amount: Double?
    @FocusState private var focused: Bool
    @State private var selectedAccountID: PersistentIdentifier?
    @State private var paymentMethod: Transaction.PaymentMethod = .bankTransfer
    @State private var date: Date = .now
    
    private var selectedAccount: Account? {
        accounts.first(where: { $0.persistentModelID == selectedAccountID })
    }
    
    let transactionRepository =  TransactionRepository()
    
    var body: some View {
        Form {
            Section {
                AmountTextField(amount: $amount, signMode: .positiveOnly)
                    .focused($focused)
                TextField("Description", text: $title)
#if !os(macOS)
                    .textInputAutocapitalization(.words)
#endif
                    .autocorrectionDisabled()
                AccountPicker(id: $selectedAccountID, title: String(localized: "Account"))
                PaymentMethodPicker(paymentMethod: $paymentMethod)
                DatePicker("Date", selection: $date, displayedComponents: [.date])
            } footer: {
                if let account = selectedAccount {
                    let balance = account.latestBalance
                    HStack {
                        if let bank = account.bank {
                            Text(bank.name)
                            Text(" • ")
                        }
                        Text(account.name)
                        Text(" • ")
                        if let amount {
                            Text("PreviousBalance \(balance.currencyAmount) newBalance \((balance + abs(amount)).currencyAmount)")
                        } else {
                            Text("Balance: \(balance.currencyAmount)")
                        }
                    }
                }
            }
        }
        .navigationTitle("AddIncome")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(role: .confirm, action: {
                    guard let amount, let selectedAccount else { return }
                    transactionRepository.addIncome(title: title, amount: amount, account: selectedAccount, paymentMethod: paymentMethod, date: date, context: context)
                    dismiss()
                    
                })
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedAccount == nil || amount == 0 || amount == nil)
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
        AddIncomeView()
    }
    .modelContainer(ModelContainer.shared)
}

import SwiftUI
import SwiftData

struct AddBalanceView: View {
    
    init(account: Account? = nil) {
        _selectedAccountID = State(initialValue: account?.persistentModelID)
    }
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query(sort: \Account.name, order: .forward) private var accounts: [Account]
    @State private var selectedAccountID: PersistentIdentifier?
    
    private var selectedAccount: Account? {
        accounts.first(where: { $0.persistentModelID == selectedAccountID })
    }
    
    @State private var date: Date = .now
    @State private var newBalance: Double?
    @FocusState private var focused: Bool
    let balanceRepository = BalanceRepository()
    
    var body: some View {
        
        Form {
            Section {
                AmountTextField(amount: $newBalance, signMode: selectedAccount?.category == .loan ? .negativeOnly : .both)
                    .focused($focused)
                    .onChange(of: selectedAccount?.category) { _, new in
                        if new == .loan {
                            newBalance = nil
                        }
                    }
                AccountPicker(id: $selectedAccountID, title: String(localized: "Account"))
                DatePicker("Date", selection: $date, displayedComponents: [.date])
            }
            footer: {
                if let account = selectedAccount, let previousBalance = account.latestBalance?.balance {
                    HStack {
                        if let bank = account.bank {
                            Text(bank.name)
                            Text(" • ")
                        }
                        Text(account.name)
                        Text(" • ")
                        if let newBalance {
                            Text("PreviousBalance \(previousBalance.currencyAmount) newBalance \(newBalance.currencyAmount)")
                        } else {
                            Text("Balance: \(previousBalance.currencyAmount)")
                        }
                    }
                }
            }
        }
        .navigationTitle(String(localized: "AddBalance"))
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(role: .confirm) {
                    guard let newBalance, let selectedAccount else { return }
                    balanceRepository.add(amount: newBalance, date: date, account: selectedAccount, context: context)
                    dismiss()
                }
                .disabled(newBalance == nil || selectedAccount == nil)
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
    NavigationStack {
        AddBalanceView(account: nil)
            .modelContainer(ModelContainer.shared)
    }
}

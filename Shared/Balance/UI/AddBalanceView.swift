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
    @State private var amountText: String = ""
    @FocusState private var focused: Bool
    let balanceRepository = BalanceRepository()
    
    var newBalance: Double? {
        Double(amountText.replacingOccurrences(of: ",", with: "."))
    }
    
    var body: some View {
        
        Form {
            Section {
#if os(watchOS)
                NavigationLink {
                    NumericalKeyboardView(text: $amountText)
                } label: {
                    Text(amountText.isEmpty ? String(localized:"balance") : amountText)
                }
#else
                TextField("balance", text: $amountText)
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
                AccountPicker(id: $selectedAccountID, title: String(localized: "account"))
                DatePicker("date", selection: $date, displayedComponents: [.date])
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
                            Text("previousBalance \(previousBalance.toString) newBalance \(newBalance.toString)")
                        } else {
                            Text("balance: \(previousBalance.toString)")
                        }
                    }
                }
            }
        }
        .navigationTitle(String(localized: "addBalance"))
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(role: .confirm) {
                    guard let newBalance, let selectedAccount else { return }
                    balanceRepository.add(amount: newBalance, date: date, account: selectedAccount, context: context)
                    dismiss()
                }
                .disabled(Double(amountText.replacingOccurrences(of: ",", with: ".")) == nil || selectedAccount == nil)
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

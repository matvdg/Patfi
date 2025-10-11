import SwiftUI
import SwiftData

struct AddBalanceView: View {
    
    init(account: Account? = nil) {
        self.account = account
        _selectedAccountID = State(initialValue: account?.persistentModelID)
    }
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query(sort: \Account.name, order: .forward) private var accounts: [Account]
    @State private var selectedAccountID: PersistentIdentifier?

    private var selectedAccount: Account? {
        accounts.first(where: { $0.persistentModelID == selectedAccountID })
    }
    
    var account: Account?
    
    @State private var date: Date = .now
    @State private var amountText: String = ""
    @FocusState private var focused: Bool
    let balanceRepository = BalanceRepository()
    
    var body: some View {
        Form {
            TextField("Balance", text: $amountText)
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
            DatePicker("Date", selection: $date, displayedComponents: [.date])
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
        }
        .navigationTitle(String(localized: "Add balance"))
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(role: .confirm) {
                    guard let amount = Double(amountText.replacingOccurrences(of: ",", with: ".")) else { return }
                    guard let selected = selectedAccount else { return }
                    balanceRepository.add(amount: amount, date: date, account: selected, context: context)
                    dismiss()
                }
                .disabled(Double(amountText.replacingOccurrences(of: ",", with: ".")) == nil)
            }
        }
        .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { focused = true } }
        .formStyle(.grouped)
    }
}

#Preview {
    AddBalanceView(account: nil)
}

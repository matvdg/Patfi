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
    @State private var amountText: String = ""
    @State private var account: Account? = nil
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
        .navigationTitle("Add income")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(role: .confirm, action: {
                    guard let amount, let account else { return }
                    transactionRepository.addIncome(title: title, amount: amount, account: account, context: context)
                    dismiss()
                    
                })
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || account == nil || amount == nil)
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

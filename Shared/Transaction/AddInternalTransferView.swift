import SwiftUI
import SwiftData

struct AddInternalTransferView: View {
    
    init(sourceAccount: Account? = nil) {
        _sourceAccountID = State(initialValue: sourceAccount?.persistentModelID)
    }
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @Query(sort: \Account.name, order: .forward) private var accounts: [Account]
    
    @State private var amountText: String = ""
    @State private var destinationAccount: Account? = nil
    @FocusState private var focused: Bool
    @State private var sourceAccountID: PersistentIdentifier?
    
    private var sourceAccount: Account? {
        accounts.first(where: { $0.persistentModelID == sourceAccountID })
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
                HStack {
                    if let bank = sourceAccount?.bank {
                        BankLogo(bank: bank)
                            .id(bank.id)
                    }
                    Picker("Source account", selection: $sourceAccountID) {
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
                    if let bank = destinationAccount?.bank {
                        BankLogo(bank: bank)
                            .id(bank.id)
                    }
                    Picker("Destination account", selection: $destinationAccount) {
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
            } footer: {
                VStack(alignment: .leading, spacing: 8) {
                    if let sourceAccount, let balance = sourceAccount.latestBalance?.balance {
                        if let amount {
                            HStack {
                                Text(sourceAccount.name)
                                Text(" • ")
                                Text("Previous balance: \(balance.toString), new balance: \((balance - amount).toString)")
                            }
                        } else {
                            HStack {
                                Text(sourceAccount.name)
                                Text(" • ")
                                Text("Balance: \(balance.toString)")
                            }
                        }
                    }
                    if let destinationAccount, let balance = destinationAccount.latestBalance?.balance {
                        if let amount {
                            HStack {
                                Text(destinationAccount.name)
                                Text(" • ")
                                Text("Previous balance: \(balance.toString), new balance: \((balance + amount).toString)")
                            }
                        } else {
                            HStack {
                                Text(destinationAccount.name)
                                Text(" • ")
                                Text("Balance: \(balance.toString)")
                            }
                        }
                    }
                }
                .font(.footnote)
                .foregroundColor(.secondary)
                .italic()
            }
        }
        .navigationTitle("Internal transfer")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(role: .confirm, action: {
                    guard let amount, let sourceAccount, let destinationAccount else { return }
                    let internalTransfer = String(localized: "Internal transfer")
                    transactionRepository.addInternalTransfer(title: internalTransfer, amount: amount, sourceAccount: sourceAccount, destinationAccount: destinationAccount, context: context)
                    dismiss()
                    
                })
                .disabled(sourceAccount == nil || destinationAccount == nil || amount == nil)
            }
        }
        .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { focused = true } }
        .formStyle(.grouped)
        .onChange(of: accounts, initial: true) { _, newAccounts in
            if sourceAccountID == nil,
               let defaultAccount = newAccounts.first(where: { $0.isDefault }) {
                sourceAccountID = defaultAccount.persistentModelID
            }
        }
}
}

#Preview {
    NavigationStack{
        AddInternalTransferView()
    }
    .modelContainer(ModelContainer.shared)
}

import SwiftUI
import SwiftData

struct AddInternalTransferView: View {
    
    init(sourceAccount: Account? = nil) {
        _sourceAccountID = State(initialValue: sourceAccount?.persistentModelID)
    }
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @Query(sort: \Account.name, order: .forward) private var accounts: [Account]
    
    @State private var amount: Double?
    @FocusState private var focused: Bool
    @State private var sourceAccountID: PersistentIdentifier?
    @State private var destinationAccountID: PersistentIdentifier?
    @State private var date: Date = .now
    @State private var markAsDavingsInvestments: Bool = false
    @State private var title: String = String(localized: "internalTransfer")
    
    private var sourceAccount: Account? {
        accounts.first(where: { $0.persistentModelID == sourceAccountID })
    }
    
    private var destinationAccount: Account? {
        accounts.first(where: { $0.persistentModelID == destinationAccountID })
    }
    
    let transactionRepository =  TransactionRepository()
    
    var body: some View {
        Form {
            Section {
                AmountTextField(amount: $amount, signMode: .positiveOnly)
                    .focused($focused)
                TextField("description", text: $title)
                AccountPicker(id: $sourceAccountID, title: String(localized: "sourceAccount"))
                AccountPicker(id: $destinationAccountID, title: String(localized: "destinationAccount"))
                DatePicker("date", selection: $date, displayedComponents: [.date])
                Toggle("markAsSavingsOrInvestment", isOn: $markAsDavingsInvestments)
            } footer: {
                VStack(alignment: .leading, spacing: 8) {
                    if let sourceAccount, let balance = sourceAccount.latestBalance?.balance {
                        HStack {
                            if let bank = sourceAccount.bank {
                                Text(bank.name)
                                Text(" • ")
                            }
                            Text(sourceAccount.name)
                            Text(" • ")
                            if let amount {
                                Text("previousBalance \(balance.currencyAmount) newBalance \((balance - abs(amount)).currencyAmount)")
                            } else {
                                Text("balance: \(balance.currencyAmount)")
                            }
                        }
                    }
                    if let destinationAccount, let balance = destinationAccount.latestBalance?.balance {
                        HStack {
                            if let bank = destinationAccount.bank {
                                Text(bank.name)
                                Text(" • ")
                            }
                            Text(destinationAccount.name)
                            Text(" • ")
                            if let amount {
                                Text("previousBalance \(balance.currencyAmount) newBalance \((balance + abs(amount)).currencyAmount)")
                            } else {
                                Text("balance: \(balance.currencyAmount)")
                            }
                        }
                    }
                }
                .font(.footnote)
                .foregroundColor(.secondary)
                .italic()
            }
        }
        .navigationTitle("internalTransfer")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(role: .confirm, action: {
                    guard let amount, let sourceAccount, let destinationAccount else { return }
                    transactionRepository.addInternalTransfer(title: title, amount: amount, sourceAccount: sourceAccount, destinationAccount: destinationAccount, date: date, markAsDavingsInvestments: markAsDavingsInvestments, context: context)
                    dismiss()
                    
                })
                .disabled(sourceAccount == nil || destinationAccount == nil || amount == 0 || amount == nil)
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

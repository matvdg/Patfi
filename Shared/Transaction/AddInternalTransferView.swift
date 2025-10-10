import SwiftUI
import SwiftData

struct AddInternalTransferView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @Query(sort: \Account.name, order: .forward) private var accounts: [Account]
    
    @State private var amountText: String = ""
    @State private var sourceAccount: Account? = nil
    @State private var destinationAccount: Account? = nil
    @FocusState private var focused: Bool
    
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
            HStack {
                if let bank = sourceAccount?.bank {
                    BankLogo(bank: bank)
                        .id(bank.id)
                }
                Picker("Source Account", selection: $sourceAccount) {
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
                if let bank = destinationAccount?.bank {
                    BankLogo(bank: bank)
                        .id(bank.id)
                }
                Picker("Destination Account", selection: $destinationAccount) {
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
    }
}

#Preview {
    NavigationStack{
        AddInternalTransferView()
    }
    .modelContainer(ModelContainer.getSharedContainer())
}

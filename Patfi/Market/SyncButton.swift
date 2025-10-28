import SwiftUI

struct SyncButton: View {
    
    var account: Account
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Label("SyncWith", systemImage: "arrow.trianglehead.2.clockwise.rotate.90")
            HStack(spacing: 4) {
                if let bank = account.bank {
                    BankLogo(bank: bank)
                    Text(bank.name)
                }
                Text(account.name)
            }
            
            .font(.default)
        }
#if os(visionOS)
        .buttonStyle(.borderedProminent)
#else
        .buttonStyle(.glassProminent)
#endif
    }
}

#Preview {
    let revolut = Bank(name: "Revolut", color: .blue, logoAvaibility: .available)
    let bourso = Bank(name: "BoursoBank", color: .blue, logoAvaibility: .available)
    let account = Account(name: " AAPL", category: .stocks, currentBalance: 1000, bank: revolut)
    let account1 = Account(name: "Airbus", category: .stocks, currentBalance: 1000, bank: bourso)
    let account2 = Account(name: "Bitcoins", category: .stocks, currentBalance: 1000, bank: nil)
    let action: () -> Void = { print("Syncing...") }
    SyncButton(account: account, action: action)
    SyncButton(account: account1, action: action)
    SyncButton(account: account2, action: action)
}

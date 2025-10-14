import SwiftUI

struct AccountRow: View {
    
    var account: Account
    var displayBankLogo: Bool = true
    var displayBalance: Bool = false
    
    var body: some View {
        
        HStack(alignment: .center, spacing: 8) {
            if let bank = account.bank, displayBankLogo {
                BankLogo(bank: bank)
            } else {
                Circle()
                    .fill(Color(account.bank?.swiftUIColor ?? .gray))
                    .frame(width: 10, height: 10)
            }
            Text(account.name)
                .font(.headline)
                .foregroundColor(.primary)
            if displayBalance {
                Spacer()
                Text((account.latestBalance?.balance ?? 0).toString)
                    .font(.body)
                    .bold()
            }
        }
        .lineLimit(1)
        .minimumScaleFactor(0.1)
    }
}

#Preview {
    VStack {
        AccountRow(account: Account(name: "CAV", category: .current, bank: Bank(name: "Revolut", color: .blue)))
        AccountRow(account: Account(name: "Blue", category: .current, bank: Bank(name: "Blue", color: .blue, logoAvaibility: .optedOut)))
        AccountRow(account: Account(name: "Red", category: .current, bank: Bank(name: "Red", color: .red, logoAvaibility: .optedOut)))
        AccountRow(account: Account(name: "GGPlanet", category: .lifeInsurance, bank: Bank(name: "GreenGot", color: .green)))
        AccountRow(account: Account(name: "Crypto", category: .crypto, bank: Bank(name: "TradeRepublic", color: .gray)))
        AccountRow(account: Account(name: "LA", category: .savings, bank: Bank(name: "BoursoBank", color: .purple)))
        Divider()
        AccountRow(account: Account(name: "CAV", category: .current, bank: Bank(name: "Revolut", color: .blue)), displayBankLogo: false)
        AccountRow(account: Account(name: "GGPlanet", category: .lifeInsurance, bank: Bank(name: "GreenGot", color: .green)), displayBankLogo: false)
        AccountRow(account: Account(name: "Crypto", category: .crypto, bank: Bank(name: "TradeRepublic", color: .gray)), displayBankLogo: false)
        AccountRow(account: Account(name: "LA", category: .savings, bank: Bank(name: "BoursoBank", color: .purple)), displayBankLogo: false)
        AccountRow(account: Account(name: "Red", category: .savings, bank: Bank(name: "Red", color: .red)), displayBankLogo: false)
    }.padding(20)
}

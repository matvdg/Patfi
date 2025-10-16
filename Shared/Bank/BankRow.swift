import SwiftUI

struct BankRow: View {
    
    var bank: Bank

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            BankLogo(bank: bank)
            let name = bank.name == "?" ? String(localized: "noBank") : bank.name
            Text(name)
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.1)
        }
    }
}

#Preview {
    BankRow(bank: Bank(name: "BoursoBank", color: .purple))
    BankRow(bank: Bank(name: "GreenGot", color: .green))
    BankRow(bank: Bank(name: "BNP Paribas", color: .green))
    BankRow(bank: Bank(name: "Crypto", color: .blue))
    BankRow(bank: Bank(name: "Trade Republic", color: .gray))
    BankRow(bank: Bank(name: "Revolut", color: .yellow))
    BankRow(bank: Bank(name: "La Banque Postale", color: .yellow))
    BankRow(bank: Bank(name: "Société Générale", color: .red))
    BankRow(bank: Bank(name: "Caisse d'Epargne", color: .red))
    BankRow(bank: Bank(name: "Banque populaire", color: .blue))
    BankRow(bank: Bank(name: "CIC", color: .green))
    BankRow(bank: Bank(name: "Crédit mutuel", color: .red))
    BankRow(bank: Bank(name: "N26", color: .green))
}


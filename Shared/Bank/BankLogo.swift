import SwiftUI

struct BankLogo: View {
    
    @Bindable var bank: Bank
    @State private var logoImage: Image? = nil
    
    var body: some View {
        Group {
            if let logoImage = logoImage {
                logoImage
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 32, height: 32)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(bank.swiftUIColor)
                        .frame(width: 32, height: 32)
                    Text(bank.initialLetter)
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                }
            }
        }
        .task(priority: .high) {
            if bank.logoAvailability != .optedOut {
                logoImage = await bank.getLogo()
            } else {
                logoImage = nil
            }
        }
    }
}

#Preview {
    let columns = Array(repeating: GridItem(.flexible()), count: 4)
    LazyVGrid(columns: columns) {
        
        // Without logo
        BankLogo(bank: Bank(name: "A", color: .purple, logoAvaibility: .optedOut))
        BankLogo(bank: Bank(name: "B", color: .red, logoAvaibility: .optedOut))
        BankLogo(bank: Bank(name: "C", color: .green, logoAvaibility: .optedOut))
        
        // 🇫🇷 French Banks
        BankLogo(bank: Bank(name: "BoursoBank", color: .purple))
        BankLogo(bank: Bank(name: "GreenGot", color: .green))
        BankLogo(bank: Bank(name: "BNP Paribas", color: .green))
        BankLogo(bank: Bank(name: "Crypto", color: .blue))
        BankLogo(bank: Bank(name: "Trade Republic", color: .gray))
        BankLogo(bank: Bank(name: "Revolut", color: .blue))
        BankLogo(bank: Bank(name: "La Banque Postale", color: .yellow))
        BankLogo(bank: Bank(name: "Société Générale", color: .red))
        BankLogo(bank: Bank(name: "Caisse d'Epargne", color: .red))
        BankLogo(bank: Bank(name: "Banque Populaire", color: .blue))
        BankLogo(bank: Bank(name: "CIC", color: .green))
        BankLogo(bank: Bank(name: "Crédit Mutuel", color: .red))
        BankLogo(bank: Bank(name: "N26", color: .black))
        BankLogo(bank: Bank(name: "Crédit Agricole", color: .green))
        BankLogo(bank: Bank(name: "LCL", color: .blue))
        BankLogo(bank: Bank(name: "Fortuneo", color: .green))
        BankLogo(bank: Bank(name: "Monabanq", color: .yellow))
        BankLogo(bank: Bank(name: "BforBank", color: .gray))
        BankLogo(bank: Bank(name: "Hello bank!", color: .cyan))
        BankLogo(bank: Bank(name: "Orange Bank", color: .orange))
        BankLogo(bank: Bank(name: "AXA Banque", color: .blue))
        
        // 🇺🇸 US Banks
        BankLogo(bank: Bank(name: "JPMorgan Chase", color: .blue))
        BankLogo(bank: Bank(name: "Bank of America", color: .red))
        BankLogo(bank: Bank(name: "Wells Fargo", color: .red))
        BankLogo(bank: Bank(name: "Citibank", color: .blue))
        BankLogo(bank: Bank(name: "Goldman Sachs", color: .yellow))
        BankLogo(bank: Bank(name: "Morgan Stanley", color: .gray))
        BankLogo(bank: Bank(name: "Capital One", color: .red))
        BankLogo(bank: Bank(name: "US Bank", color: .blue))
        BankLogo(bank: Bank(name: "PNC Bank", color: .orange))
        BankLogo(bank: Bank(name: "TD Bank", color: .green))
        BankLogo(bank: Bank(name: "Chime", color: .green))
        BankLogo(bank: Bank(name: "Ally Bank", color: .purple))
        
        // 🇬🇧 UK Banks
        BankLogo(bank: Bank(name: "HSBC", color: .red))
        BankLogo(bank: Bank(name: "Barclays", color: .blue))
        BankLogo(bank: Bank(name: "Lloyds Bank", color: .green))
        BankLogo(bank: Bank(name: "NatWest", color: .purple))
        BankLogo(bank: Bank(name: "Monzo", color: .pink))
        BankLogo(bank: Bank(name: "Starling Bank", color: .teal))
        BankLogo(bank: Bank(name: "TSB Bank", color: .blue))
        BankLogo(bank: Bank(name: "Metro Bank", color: .red))
        BankLogo(bank: Bank(name: "Halifax", color: .blue))
        BankLogo(bank: Bank(name: "Virgin Money", color: .red))
        
        // 🇪🇸 Spanish Banks
        BankLogo(bank: Bank(name: "Banco Santander", color: .red))
        BankLogo(bank: Bank(name: "BBVA", color: .blue))
        BankLogo(bank: Bank(name: "CaixaBank", color: .orange))
        BankLogo(bank: Bank(name: "Bankinter", color: .orange))
        BankLogo(bank: Bank(name: "Sabadell", color: .blue))
        BankLogo(bank: Bank(name: "Kutxabank", color: .green))
        BankLogo(bank: Bank(name: "Unicaja Banco", color: .green))
        BankLogo(bank: Bank(name: "Abanca", color: .blue))
        BankLogo(bank: Bank(name: "Ibercaja", color: .red))
    }
}

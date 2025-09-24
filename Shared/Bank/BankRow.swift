import SwiftUI

struct BankRow: View {
    
    var bank: Bank?
    @State private var logoImage: Image? = nil

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            if let logoImage = logoImage {
                logoImage
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 30, height: 30)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            } else {
                ZStack {
                    Circle()
                        .fill((bank?.swiftUIColor ?? Color.gray).opacity( bank == nil ? 0.3 : 1.0))
                        .frame(width: 14, height: 14)
                    Text(bank?.initialLetter ?? "")
                        .font(.caption2.bold())
                        .foregroundStyle(.white)
                        .opacity(bank == nil ? 0 : 1)
                }
            }
            Text(bank?.name.isEmpty == false ? (bank?.name ?? "") : (bank == nil ? String(localized: "No bank") : "—"))
                .foregroundColor(.primary)
        }
        .task(priority: .high) {
            if bank?.logoAvailability != .optedOut {
                logoImage = await bank?.getLogo()
            }
        }
    }
}

#Preview {
    BankRow()
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


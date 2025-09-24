import SwiftUI

struct AccountRowView: View {
    
    var account: Account
    var displayBankLogo: Bool = true
    @State private var logoImage: Image? = nil
    
    
    var body: some View {
        
        if displayBankLogo {
            let bank = account.bank
            HStack(alignment: .center, spacing: 8) {
                if let logoImage = logoImage {
                    logoImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: 30, height: 30)
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
                Text(account.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Text((account.latestBalance?.balance ?? 0).toString)
                    .font(.body)
                    .bold()
            }
            .task(priority: .high) {
                if bank?.logoAvailability != .optedOut {
                    logoImage = await bank?.getLogo()
                }
            }
        } else {
            HStack {
                Circle()
                    .fill(Color(account.category.color))
                    .frame(width: 20, height: 20)
                Text(account.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Text((account.latestBalance?.balance ?? 0).toString)
                    .font(.body)
                    .bold()
            }
        }
    }
}

#Preview {
    VStack {
        AccountRowView(account: Account(name: "CAV", category: .current, bank: Bank(name: "Revolut", color: .blue)))
        AccountRowView(account: Account(name: "GGPlanet", category: .lifeInsurance, bank: Bank(name: "GreenGot", color: .green)))
        AccountRowView(account: Account(name: "Crypto", category: .crypto, bank: Bank(name: "TradeRepublic", color: .gray)))
        AccountRowView(account: Account(name: "LA", category: .savings, bank: Bank(name: "BoursoBank", color: .purple)))
        Divider()
        AccountRowView(account: Account(name: "CAV", category: .current, bank: Bank(name: "Revolut", color: .blue)), displayBankLogo: false)
        AccountRowView(account: Account(name: "GGPlanet", category: .lifeInsurance, bank: Bank(name: "GreenGot", color: .green)), displayBankLogo: false)
        AccountRowView(account: Account(name: "Crypto", category: .crypto, bank: Bank(name: "TradeRepublic", color: .gray)), displayBankLogo: false)
        AccountRowView(account: Account(name: "LA", category: .savings, bank: Bank(name: "BoursoBank", color: .purple)), displayBankLogo: false)
    }.padding(20)
}

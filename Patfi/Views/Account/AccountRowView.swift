import SwiftUI

struct AccountRowView: View {
    var account: Account

    var body: some View {
        HStack {
            Circle()
                .fill(Color(account.category.color))
                .frame(width: 20, height: 20)
            VStack(alignment: .leading) {
                if let bank = account.bank?.name {
                    Text("\(bank) • \(account.name)")
                        .font(.headline)
                } else {
                    Text(account.name)
                        .font(.headline)
                }
                
                Text(account.category.localizedName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text((account.latestBalance?.balance ?? 0).toString)
                .font(.body)
                .bold()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    VStack {
        AccountRowView(account: Account(name: "CAV", category: .current, bank: Bank(name: "Revolut", color: .blue)))
        AccountRowView(account: Account(name: "GGPlanet", category: .lifeInsurance, bank: Bank(name: "GreenGot", color: .green)))
        AccountRowView(account: Account(name: "Crypto", category: .crypto, bank: Bank(name: "TradeRepublic", color: .gray)))
        AccountRowView(account: Account(name: "LA", category: .savings, bank: Bank(name: "BoursoBank", color: .purple)))
    }.padding(20)
}

import SwiftUI

struct BanksWidgetView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Spacer()
            let entry = BalanceReader.balancesByBank
            let totalBalance = BalanceReader.totalBalance
            let balancesByBank: [(bankName: String, total: Double, colorPalette: String)] = entry.compactMap { dict in
                let bankName = dict["bankName"] as? String ?? "Unknown"
                let total = dict["total"] as? Double ?? 0
                let colorPalette = dict["colorPalette"] as? String ?? "gray"
                return (bankName: bankName, total: total, colorPalette: colorPalette)
            }
            let rows = balancesByBank.sorted { $0.bankName < $1.bankName }
            ForEach(Array(rows.enumerated()), id: \.offset) { _, item in
                let bank = Bank(name: item.bankName, color: Bank.Palette(rawValue: item.colorPalette) ?? .gray)
                let logo = Bank.getLogoFromCache(normalizedName: Bank.getNormalizedName(bank.name))
                let total = item.total
                HStack {
                    if let logoImage = logo {
                        logoImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: 14, height: 14)
                    } else {
                        ZStack {
                            Circle()
                                .fill(bank.swiftUIColor)
                                .frame(width: 14, height: 14)
                            Text(bank.initialLetter)
                                .font(.caption2.bold())
                                .foregroundStyle(.white)
                        }
                    }
                    Text(bank.name.isEmpty ? "No bank" : bank.name)
                        .foregroundColor(.primary)
                        .minimumScaleFactor(0.1)
                    Spacer()
                    Text(total.toString)
                        .minimumScaleFactor(0.3)
                }
            }
            Spacer()
            HStack {
                Text("Balance")
                    .font(.headline)
                Spacer()
                Text(totalBalance.toString)
                    .font(.headline)
            }
            Spacer()
        }
        .padding()
    }
}

#Preview {
    BanksWidgetView()
}

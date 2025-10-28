import SwiftUI

struct AssetRow: View {
    
    var asset: Asset
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(asset.name)
                    .font(.headline)
                Text(asset.symbol)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("Quantity: \(asset.quantity.twoDecimalsString)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Last: \(asset.currencySymbol)\(asset.latestPrice.twoDecimalsString)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(asset.currencySymbol)\(asset.totalInAssetCurrency.twoDecimalsString)")
                    .font(.headline)
                Text("\(asset.totalInEuros.twoDecimalsString) €")
                    .font(.headline)
                    .foregroundStyle(.tint)
            }
        }
        .foregroundStyle(.black)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.9, green: 0.9, blue: 1))
                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
        )
    }
}

#Preview {
    AssetRow(
        asset: 🍏
    )
    .padding()
}

import SwiftUI

struct BankRow: View {
    
    var bank: Bank?
    @State private var logoImage: Image? = nil

    var body: some View {
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
}

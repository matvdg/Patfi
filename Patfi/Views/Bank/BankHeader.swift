import SwiftUI

struct BankHeader: View {
    
    var bank: Bank?

    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill((bank?.swiftUIColor ?? Color.gray).opacity( bank == nil ? 0.3 : 1.0))
                    .frame(width: 14, height: 14)
                Text(bank?.initialLetter ?? "")
                    .font(.caption2.bold())
                    .foregroundStyle(.white)
                    .opacity(bank == nil ? 0 : 1)
            }
            Text(bank?.name.isEmpty == false ? (bank?.name ?? "") : (bank == nil ? String(localized: "No bank") : "—"))
        }
    }
}

#Preview {
    BankHeader()
    BankHeader(bank: Bank(name: "BoursoBank", color: .purple))
}

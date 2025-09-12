import SwiftUI

struct BankRow: View {
    let bank: Bank

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(bank.swiftUIColor)
                    .frame(width: 24, height: 24)
                Text(bank.initialLetter)
                    .font(.caption.bold())
                    .foregroundStyle(.white)
            }
            Text(bank.name.isEmpty ? " " : bank.name)
                .font(.body)
            Spacer()
        }
        .contentShape(Rectangle())
    }
}


#Preview {
    BankRow(bank: Bank(name: "BoursoBank", color: .purple)).padding()
}

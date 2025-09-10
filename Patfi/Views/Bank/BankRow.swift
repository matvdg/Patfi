import SwiftUI

struct BankRow: View {
    let bank: Bank

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(bank.swiftUIColor)
                    .frame(width: 24, height: 24)
                Text(initialLetter)
                    .font(.caption.bold())
                    .foregroundStyle(.white)
            }
            Text(bank.name.isEmpty ? " " : bank.name)
                .font(.body)
            Spacer()
        }
        .contentShape(Rectangle())
    }

    private var initialLetter: String {
        let trimmed = bank.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.first.map { String($0).uppercased() } ?? " "
    }
}


#Preview {
    BankRow(bank: Bank(name: "BoursoBank", color: .purple)).padding()
}

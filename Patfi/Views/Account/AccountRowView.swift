import SwiftUI

struct AccountRowView: View {
    var account: Account

    var body: some View {
        HStack {
            Circle()
                .fill(Color(account.category.color))
                .frame(width: 20, height: 20)
            VStack(alignment: .leading) {
                Text(account.name)
                    .font(.headline)
                Text(account.category.localizedName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text((account.latestBalance?.balance ?? 0).formattedAmount)
                .font(.body)
                .bold()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    VStack {
        AccountRowView(account: Account(name: "BoursoBank", category: .current))
        AccountRowView(account: Account(name: "GreenGot", category: .savings))
        AccountRowView(account: Account(name: "Crypto", category: .crypto))
    }.padding(20)
}

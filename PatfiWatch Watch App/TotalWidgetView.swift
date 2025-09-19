import SwiftUI

struct TotalWidgetView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            let balance = BalanceReader.totalBalance
            HStack(alignment: .center, spacing: 8) {
                Bank.sfSymbol
                Text("Patfi")
                    .font(.headline)
            }
            Text(balance.toString)
                .font(.largeTitle)
                .bold()
                .minimumScaleFactor(0.2)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    TotalWidgetView()
}

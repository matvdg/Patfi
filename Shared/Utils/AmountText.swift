import SwiftUI

struct AmountText: View {
    
    var amount: Double?
    var placeholder: String = String(localized: "Amount")
    
    var body: some View {
        Group {
            if let amount {
                switch amount {
                case ..<0:
                    Text(amount.currencyAmount).foregroundStyle(.red)
                case 0:
                    Text(amount.currencyAmount)
                default:
                    Text(amount.currencyAmount).foregroundStyle(.green)
                }
            } else {
                Text(placeholder)
            }
        }
        .lineLimit(1)
        .bold()
        #if os(watchOS)
        .minimumScaleFactor(0.5)
        #endif
    }
}

#Preview {
    VStack {
        AmountText(amount: 2344.9999)
        AmountText(amount: 2344.99)
        AmountText(amount: 0)
        AmountText(amount: -2344.9999)
        AmountText(amount: nil)
    }
}

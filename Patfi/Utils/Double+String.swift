import Foundation

extension Double {
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = Locale.current.currency?.identifier ?? "$"
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

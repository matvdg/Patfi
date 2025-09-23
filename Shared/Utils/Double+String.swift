import Foundation

extension Double {
    
    var toString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = Locale.current.currency?.identifier ?? "€"
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }

    var toShortString: String {
        let absValue = abs(self)
        let sign = self < 0 ? "-" : ""
        switch absValue {
        case 1_000_000_000...:
            let value = (absValue / 1_000_000_000).rounded(.towardZero)
            let str = (absValue / 1_000_000_000).truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(value))" : String(format: "%.1f", absValue / 1_000_000_000)
            return "\(sign)\(str)B"
        case 1_000_000...:
            let value = (absValue / 1_000_000).rounded(.towardZero)
            let str = (absValue / 1_000_000).truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(value))" : String(format: "%.1f", absValue / 1_000_000)
            return "\(sign)\(str)M"
        case 1_000...:
            let value = (absValue / 1_000).rounded(.towardZero)
            let str = (absValue / 1_000).truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(value))" : String(format: "%.1f", absValue / 1_000)
            return "\(sign)\(str)K"
        default:
            if self.truncatingRemainder(dividingBy: 1) == 0 {
                return "\(Int(self))"
            } else {
                return String(format: "%.2f", self)
            }
        }
    }
}

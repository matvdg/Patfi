import Foundation

extension NumberFormatter {
    
    static func getCurrencyFormatter() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter
    }
}

extension Double {
    
    func isAlmostEqual(to other: Double) -> Bool {
        let roundedSelf = (self * 100).rounded() / 100
        let roundedOther = (other * 100).rounded() / 100
        return roundedSelf == roundedOther
    }
    
    var currencyAmount: String {
        NumberFormatter.getCurrencyFormatter().string(from: NSNumber(value: self)) ?? String(localized: "Amount")
    }

    var toDateStyleShortString: String {
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
    
    var twoDecimalsString: String {
        String(format: "%.2f", self)
    }
}

extension Double? {
    var currencyAmount: String {
        guard let amount = self else { return String(localized: "Amount") }
        return amount.currencyAmount
    }
}

extension String {
    var cleanComa: String {
        replacingOccurrences(of: ",", with: ".").cleanSpaces
    }
    var cleanSpaces: String {
        replacingOccurrences(of: "\\s", with: "", options: .regularExpression)
    }
}

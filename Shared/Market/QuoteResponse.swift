import Foundation

struct QuoteResponse: Codable, Identifiable {
    let id = UUID()
    let symbol: String
    let name: String?
    let instrumentName: String?
    let currency: String?
    let country: String?
    let instrumentType: String?
    let exchange: String?
    let open: String?
    let high: String?
    let low: String?
    let close: String?
    let volume: String?
    let previousClose: String?
    let change: String?
    let percentChange: String?
    let averageVolume: String?
    let isMarketOpen: Bool?
    let marketCap: String?
    let fiftyTwoWeek: FiftyTwoWeek?
    
    struct FiftyTwoWeek: Codable {
        let low: String?
        let high: String?
        let lowChange: String?
        let highChange: String?
        let lowChangePercent: String?
        let highChangePercent: String?
        let range: String?
        
        enum CodingKeys: String, CodingKey {
            case low
            case high
            case lowChange = "low_change"
            case highChange = "high_change"
            case lowChangePercent = "low_change_percent"
            case highChangePercent = "high_change_percent"
            case range
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case symbol
        case exchange
        case name
        case instrumentName = "instrument_name"
        case instrumentType = "instrument_type"
        case currency
        case country
        case open
        case high
        case low
        case close
        case volume
        case previousClose = "previous_close"
        case change
        case percentChange = "percent_change"
        case averageVolume = "average_volume"
        case isMarketOpen = "is_market_open"
        case marketCap = "market_cap"
        case fiftyTwoWeek = "fifty_two_week"
    }
    
    var flag: String {
        guard let country else { return "🏳️" }
        let locale = Locale(identifier: "en_US")
        if let code = locale.isoCode(for: country) {
            return code.unicodeScalars.reduce(into: "") {
                $0.unicodeScalars.append(UnicodeScalar(127397 + $1.value)!)
            }
        }
        return "🏳️"
    }
    
    var currencySymbol: String {
        guard let currency else { return "" }
        let locale = Locale(identifier: "en_US")
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.locale = locale
        let symbolChar = formatter.currencySymbol ?? currency
        return symbolChar
    }
}

struct SymbolSearchResponse: Codable {
    let data: [QuoteResponse]
}

extension Locale {
    func isoCode(for countryName: String) -> String? {
        return Locale.Region.isoRegions.first {
            self.localizedString(forRegionCode: $0.identifier)?
                .lowercased() == countryName.lowercased()
        }?.identifier
    }
}

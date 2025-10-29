import Foundation
import SwiftData

@Model
final class QuoteResponse: Identifiable, Decodable {
    
    init() {}
    
    convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.symbol = try container.decodeIfPresent(String.self, forKey: .symbol)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.instrumentName = try container.decodeIfPresent(String.self, forKey: .instrumentName)
        self.currency = try container.decodeIfPresent(String.self, forKey: .currency)
        self.country = try container.decodeIfPresent(String.self, forKey: .country)
        self.instrumentType = try container.decodeIfPresent(String.self, forKey: .instrumentType)
        self.exchange = try container.decodeIfPresent(String.self, forKey: .exchange)
        self.open = try container.decodeIfPresent(String.self, forKey: .open)
        self.high = try container.decodeIfPresent(String.self, forKey: .high)
        self.low = try container.decodeIfPresent(String.self, forKey: .low)
        self.close = try container.decodeIfPresent(String.self, forKey: .close)
        self.volume = try container.decodeIfPresent(String.self, forKey: .volume)
        self.previousClose = try container.decodeIfPresent(String.self, forKey: .previousClose)
        self.change = try container.decodeIfPresent(String.self, forKey: .change)
        self.percentChange = try container.decodeIfPresent(String.self, forKey: .percentChange)
        self.averageVolume = try container.decodeIfPresent(String.self, forKey: .averageVolume)
        self.isMarketOpen = try container.decodeIfPresent(Bool.self, forKey: .isMarketOpen)
        self.marketCap = try container.decodeIfPresent(String.self, forKey: .marketCap)
        self.fiftyTwoWeek = try container.decodeIfPresent(FiftyTwoWeek.self, forKey: .fiftyTwoWeek)
    }
    
    var symbol: String?
    var name: String?
    var instrumentName: String?
    var currency: String?
    var country: String?
    var instrumentType: String?
    var exchange: String?
    var open: String?
    var high: String?
    var low: String?
    var close: String?
    var volume: String?
    var previousClose: String?
    var change: String?
    var percentChange: String?
    var averageVolume: String?
    var isMarketOpen: Bool?
    var marketCap: String?
    var fiftyTwoWeek: FiftyTwoWeek?

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

    var flag: String? {
        guard let country else { return nil }
        let locale = Locale(identifier: "en_US")
        let isoCode = Locale.Region.isoRegions.first {
            locale.localizedString(forRegionCode: $0.identifier)?
                .lowercased() == country.lowercased()
        }?.identifier
        if let code = isoCode {
            return code.unicodeScalars.reduce(into: "") {
                $0.unicodeScalars.append(UnicodeScalar(127397 + $1.value)!)
            }
        }
        return nil
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

struct SymbolSearchResponse: Decodable {
    let data: [QuoteResponse]
}

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

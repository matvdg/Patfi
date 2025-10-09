import SwiftUI

enum Category: String, Codable, CaseIterable, Identifiable {
    case current, savings, crypto, stocks, lifeInsurance, loan, commodities, other

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .current: return .blue
        case .savings: return .yellow
        case .crypto: return .purple
        case .stocks: return .orange
        case .lifeInsurance: return .green
        case .loan: return .red
        case .commodities: return .brown
        case .other: return .gray
        }
    }
    
    var localized: String {
        String(localized: localizedName)
    }
    
    private var localizedName: LocalizedStringResource {
        switch self {
        case .current:       "category.current"
        case .savings:       "category.savings"
        case .crypto:        "category.crypto"
        case .stocks:        "category.stocks"
        case .lifeInsurance: "category.lifeInsurance"
        case .loan:          "category.loan"
        case .commodities:   "category.commodities"
        case .other:         "category.other"
        }
    }
    
}

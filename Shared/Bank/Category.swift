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
        switch self {
        case .current:       String(localized: "category.current")
        case .savings:       String(localized: "category.savings")
        case .crypto:        String(localized: "category.crypto")
        case .stocks:        String(localized: "category.stocks")
        case .lifeInsurance: String(localized: "category.lifeInsurance")
        case .loan:          String(localized: "category.loan")
        case .commodities:   String(localized: "category.commodities")
        case .other:         String(localized: "category.other")
        }
    }
    
}

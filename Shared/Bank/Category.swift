import SwiftUI

enum Category: String, Codable, CaseIterable, Identifiable {
    
    case current, savings, crypto, stocks, bonds, lifeInsurance, loan, commodities, privateEquity, other

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .current: return .blue
        case .savings: return .yellow
        case .crypto: return .purple
        case .stocks: return .orange
        case .bonds: return Color(red: 1, green: 0.6, blue: 0.0)
        case .lifeInsurance: return .green
        case .loan: return .red
        case .commodities: return .brown
        case .privateEquity: return Color(red: 0.85, green: 0.4, blue: 0.0)
        case .other: return .gray
        }
    }
    
    var localized: String {
        switch self {
        case .current:       String(localized: "category.current")
        case .savings:       String(localized: "category.savings")
        case .crypto:        String(localized: "category.crypto")
        case .stocks:        String(localized: "category.stocks")
        case .bonds:        String(localized: "category.bonds")
        case .lifeInsurance: String(localized: "category.lifeInsurance")
        case .loan:          String(localized: "category.loan")
        case .commodities:   String(localized: "category.commodities")
        case .privateEquity: String(localized: "category.privateEquity")
        case .other:         String(localized: "category.other")
        }
    }
    
}

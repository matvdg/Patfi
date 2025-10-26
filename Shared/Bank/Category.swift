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
        case .current:       String(localized: "CategoryCurrent")
        case .savings:       String(localized: "CategorySavings")
        case .crypto:        String(localized: "CategoryCrypto")
        case .stocks:        String(localized: "CategoryStocks")
        case .bonds:        String(localized: "CategoryBonds")
        case .lifeInsurance: String(localized: "CategoryLifeInsurance")
        case .loan:          String(localized: "CategoryLoan")
        case .commodities:   String(localized: "CategoryCommodities")
        case .privateEquity: String(localized: "CategoryPrivateEquity")
        case .other:         String(localized: "CategoryOther")
        }
    }
    
}

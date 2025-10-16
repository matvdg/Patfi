import SwiftUI
import Foundation

extension Transaction {
    enum ExpenseCategory: String, Codable, CaseIterable, Identifiable {
        case foodGroceries
        case diningOut
        case transportation
        case housing
        case utilities
        case insurance
        case healthcare
        case pets
        case entertainment
        case gaming
        case sportsFitness
        case shopping
        case education
        case travel
        case personalCare
        case subscriptions
        case taxes
        case debtPayment
        case giftsDonations
        case savingsInvestments
        case other
        
        var id: String { rawValue }
        
        var localized: String {
            switch self {
            case .foodGroceries: return String(localized: "expense.foodGroceries") // Groceries & food
            case .diningOut: return String(localized: "expense.diningOut") // Restaurants
            case .transportation: return String(localized: "expense.transportation") // Transportation
            case .housing: return String(localized: "expense.housing") // Housing
            case .utilities: return String(localized: "expense.utilities") // Bills & utilities
            case .insurance: return String(localized: "expense.insurance") // Insurance
            case .healthcare: return String(localized: "expense.healthcare") // Healthcare
            case .pets: return String(localized: "expense.pets") // Pets
            case .entertainment: return String(localized: "expense.entertainment") // Entertainment
            case .gaming: return String(localized: "expense.gaming") // Gaming
            case .sportsFitness: return String(localized: "expense.sportsFitness") // Sports & fitness
            case .shopping: return String(localized: "expense.shopping") // Shopping
            case .education: return String(localized: "expense.education") // Education
            case .travel: return String(localized: "expense.travel") // Travel
            case .personalCare: return String(localized: "expense.personalCare") // Personal care
            case .subscriptions: return String(localized: "expense.subscriptions") // Subscriptions (Netflix...)
            case .taxes: return String(localized: "expense.taxes") // Taxes
            case .debtPayment: return String(localized: "expense.debtPayment") // Debt & loan payments
            case .giftsDonations: return String(localized: "expense.giftsDonations") // Gifts & donations
            case .savingsInvestments: return String(localized: "expense.savingsInvestments") // Savings & investments
            case .other: return String(localized: "expense.other") // Other
            }
        }
        
        var iconName: String {
            switch self {
            case .foodGroceries: return "cart"
            case .diningOut: return "fork.knife"
            case .transportation: return "car"
            case .housing: return "house"
            case .utilities: return "bolt"
            case .insurance: return "shield"
            case .healthcare: return "cross.case"
            case .pets: return "pawprint"
            case .entertainment: return "film"
            case .gaming: return "gamecontroller"
            case .sportsFitness: return "basketball"
            case .shopping: return "bag"
            case .education: return "book"
            case .travel: return "globe.europe.africa"
            case .personalCare: return "comb"
            case .subscriptions: return "play.rectangle"
            case .taxes: return "building.columns"
            case .debtPayment: return "creditcard"
            case .giftsDonations: return "gift"
            case .savingsInvestments: return "chart.line.uptrend.xyaxis"
            case .other: return "ellipsis.circle"
            }
        }
        
        var color: Color {
            switch self {
            case .foodGroceries: return Color(red: 0.85, green: 0.4, blue: 0.0)
            case .diningOut: return Color(red: 1, green: 0.5, blue: 0)
            case .transportation: return .blue
            case .housing: return .brown
            case .utilities: return .yellow
            case .insurance: return .purple
            case .healthcare: return Color(red: 0.0, green: 0.3, blue: 0.0)
            case .pets: return Color(red: 0.0, green: 0.6, blue: 0.0)
            case .entertainment: return .pink
            case .gaming: return .pink
            case .sportsFitness: return .red
            case .shopping: return .mint
            case .education: return .teal
            case .travel: return .indigo
            case .personalCare: return .cyan
            case .subscriptions: return Color(red: 0.7, green: 0, blue: 0)
            case .taxes: return Color(red: 1, green: 0.6, blue: 0.0)
            case .debtPayment: return Color(red: 1, green: 0.8, blue: 0.0)
            case .giftsDonations: return Color(red: 1.0, green: 0.0, blue: 1.0)
            case .savingsInvestments: return Color(red: 0.6, green: 0.9, blue: 0.6)
            case .other: return .secondary
            }
        }
    }
}

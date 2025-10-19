import Foundation

enum Mode: String, CaseIterable, Identifiable {
    case accounts, expenses
    var id: String { rawValue }
    var localized: LocalizedStringResource {
        switch self {
        case .accounts: return "accounts"
        case .expenses: return "expenses"
        }
    }
}

enum WatchMode: String, CaseIterable, Identifiable {
    case categories, banks, expenses, paymentMethod
    var id: String { rawValue }
    var localized: LocalizedStringResource {
        switch self {
        case .categories: return "categories"
        case .banks: return "banks"
        case .expenses: return "expenses"
        case .paymentMethod: return "paymentMethod"
        }
    }
}

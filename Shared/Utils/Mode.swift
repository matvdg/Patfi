import Foundation

enum Mode: String, CaseIterable, Identifiable {
    case accounts, expenses
    var id: String { rawValue }
    var localized: LocalizedStringResource {
        switch self {
        case .accounts: return "Accounts"
        case .expenses: return "Expenses"
        }
    }
}

enum WatchMode: String, CaseIterable, Identifiable {
    case categories, banks, expenses, paymentMethod
    var id: String { rawValue }
    var localized: LocalizedStringResource {
        switch self {
        case .categories: return "Categories"
        case .banks: return "Banks"
        case .expenses: return "Expenses"
        case .paymentMethod: return "PaymentMethod"
        }
    }
}

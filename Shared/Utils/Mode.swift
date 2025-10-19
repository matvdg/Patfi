import Foundation

enum Mode: String, CaseIterable, Identifiable {
    case categories, banks, expenses
    var id: String { rawValue }
    var localized: LocalizedStringResource {
        switch self {
        case .categories: return "categories"
        case .banks: return "banks"
        case .expenses: return "expenses"
        }
    }
}

import Foundation

enum Period: String, CaseIterable, Identifiable {
    case days, weeks, months, years
    var id: String { rawValue }
    var localized: LocalizedStringResource {
        switch self {
        case .days: return "days"
        case .weeks: return "weeks"
        case .months: return "months"
        case .years: return "years"
        }
    }
}

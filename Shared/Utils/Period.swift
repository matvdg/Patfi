import Foundation

enum Period: String, CaseIterable, Identifiable {
    case day, week, month, year
    var id: String { rawValue }
    var component: Calendar.Component {
        switch self {
        case .day:
            return .day
        case .week:
            return .weekOfYear
        case .month:
            return .month
        case .year:
            return .year
        }
    }
    var localized: LocalizedStringResource {
        switch self {
        case .day: return "Day"
        case .week: return "Week"
        case .month: return "Month"
        case .year: return "Year"
        }
    }
}

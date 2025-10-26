import Foundation
import SwiftData

@Model
final class BalanceSnapshot: Identifiable, Hashable {
    
    #Index<BalanceSnapshot>([\.date])
    
    var date: Date = Date()
    var balance: Double = 0.0
    var account: Account? = nil

    init(date: Date = Date(), balance: Double = 0.0, account: Account? = nil) {
        self.date = date
        self.balance = balance
        self.account = account
    }
}

extension BalanceSnapshot {
    static func predicate(for selectedPeriod: Period, containing date: Date) -> Predicate<BalanceSnapshot> {
        let calendar = Calendar.current
        let start: Date
        let end: Date

        switch selectedPeriod {
        case .day:
            let startOfDay = calendar.startOfDay(for: date)
            start = calendar.date(byAdding: .day, value: -12, to: startOfDay)!
            end = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        case .week:
            let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: date)!.start
            start = calendar.date(byAdding: .weekOfYear, value: -12, to: startOfWeek)!
            end = calendar.date(byAdding: .weekOfYear, value: 1, to: startOfWeek)!
        case .month:
            let startOfMonth = calendar.dateInterval(of: .month, for: date)!.start
            start = calendar.date(byAdding: .month, value: -12, to: startOfMonth)!
            end = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
        case .year:
            let startOfYear = calendar.dateInterval(of: .year, for: date)!.start
            start = calendar.date(byAdding: .year, value: -5, to: startOfYear)!
            end = calendar.date(byAdding: .year, value: 1, to: startOfYear)!
        }

        return #Predicate { $0.date >= start && $0.date < end }
    }
}

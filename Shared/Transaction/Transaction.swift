import Foundation
import SwiftData
import SwiftUI

@Model
final class Transaction {
    
    #Index<Transaction>([\.date])

    var title: String = ""
    var date: Date = Date()
    
    /// Always positive (transactionType expense or income will infer the sign -/+)
    var amount: Double = 0.0
    var account: Account? = nil
    var transactionType = TransactionType.income
    var paymentMethod = PaymentMethod.bankTransfer
    var expenseCategory: ExpenseCategory? = nil
    /// True if this transaction is an internal transfer between accounts
    var isInternalTransfer: Bool = false
    var lat: Double? = nil
    var lng: Double? = nil

    init(
        title: String,
        transactionType: TransactionType,
        paymentMethod: PaymentMethod,
        expenseCategory: ExpenseCategory? = nil,
        date: Date,
        amount: Double,
        account: Account? = nil,
        isInternalTransfer: Bool = false,
        lat: Double? = nil,
        lng: Double? = nil
    ) {
        self.title = title
        self.date = date
        self.amount = amount // Always positive (transactionType expense or income will infer the sign -/+)
        self.account = account
        self.transactionType = transactionType
        self.paymentMethod = paymentMethod
        self.isInternalTransfer = isInternalTransfer
        self.expenseCategory = expenseCategory
        self.lat = lat
        self.lng = lng
    }
    
    enum TransactionType: String, Codable, CaseIterable, Identifiable {
        case expense
        case income

        var id: String { rawValue }

        var localized: String {
            switch self {
            case .expense: return String(localized: "Expense")
            case .income: return String(localized: "Income")
            }
        }
    }

}

extension Transaction {
    static func predicate(for selectedPeriod: Period, containing date: Date) -> Predicate<Transaction> {
        let calendar = Calendar.current
        let start: Date
        let end: Date

        switch selectedPeriod {
        case .day:
            start = calendar.startOfDay(for: date)
            end = calendar.date(byAdding: .day, value: 1, to: start)!
        case .week:
            let interval = calendar.dateInterval(of: .weekOfYear, for: date)!
            start = interval.start
            end = interval.end
        case .month:
            let interval = calendar.dateInterval(of: .month, for: date)!
            start = interval.start
            end = interval.end
        case .year:
            let interval = calendar.dateInterval(of: .year, for: date)!
            start = interval.start
            end = interval.end
        }

        return #Predicate { $0.date >= start && $0.date < end }
    }
}
 

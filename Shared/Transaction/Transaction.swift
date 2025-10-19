import Foundation
import SwiftData
import SwiftUI

@Model
final class Transaction {
    
    var title: String = ""
    var date: Date = Date()
    
    /// Always positive (transactionType expense or income will infer the sign -/+)
    var amount: Double = 0.0
    var account: Account? = nil
    var transactionType: TransactionType
    var paymentMethod: PaymentMethod
    var expenseCategory: ExpenseCategory? = nil
    /// True if this transaction is an internal transfer between accounts
    var isInternalTransfer: Bool = false

    init(
        title: String,
        transactionType: TransactionType,
        paymentMethod: PaymentMethod,
        expenseCategory: ExpenseCategory? = nil,
        date: Date,
        amount: Double,
        account: Account? = nil,
        isInternalTransfer: Bool = false
    ) {
        self.title = title
        self.date = date
        self.amount = amount // Always positive (transactionType expense or income will infer the sign -/+)
        self.account = account
        self.transactionType = transactionType
        self.paymentMethod = paymentMethod
        self.isInternalTransfer = isInternalTransfer
        self.expenseCategory = expenseCategory
    }
    
    enum TransactionType: String, Codable, CaseIterable, Identifiable {
        case expense
        case income

        var id: String { rawValue }

        var localized: String {
            switch self {
            case .expense: return String(localized: "transaction.expense")
            case .income: return String(localized: "transaction.income")
            }
        }
    }

}

extension Transaction {
    static func predicate(forMonth month: Date) -> Predicate<Transaction> {
        let calendar = Calendar.current
        let start = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
        let end = calendar.date(byAdding: .month, value: 1, to: start)!
        return #Predicate { $0.date >= start && $0.date < end }
    }
}
 

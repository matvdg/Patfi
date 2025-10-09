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
    var transactionType: TransactionType = TransactionType.expense
    var paymentMethod: PaymentMethod? = nil
    /// True if this transaction is an internal transfer between accounts
    var isInternalTransfer: Bool = false

    init(
        title: String,
        transactionType: TransactionType,
        paymentMethod: PaymentMethod? = nil,
        date: Date,
        amount: Double,
        account: Account?,
        isInternalTransfer: Bool = false
    ) {
        self.title = title
        self.date = date
        self.amount = amount // Always positive (transactionType expense or income will infer the sign -/+)
        self.account = account
        self.transactionType = transactionType
        self.paymentMethod = paymentMethod
        self.isInternalTransfer = isInternalTransfer
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
    
    enum PaymentMethod: String, Codable, CaseIterable, Identifiable {
        case applePay
        case creditCard
        case cheque
        case cashWithdrawal
        case bankTransfer

        var id: String { rawValue }

        var localized: String {
            switch self {
            case .applePay:
                return String(localized: "payment.applePay")
            case .creditCard:
                return String(localized: "payment.creditCard")
            case .cheque:
                return String(localized: "payment.cheque")
            case .cashWithdrawal:
                return String(localized: "payment.cashWithdrawal") // Retrait
            case .bankTransfer:
                return String(localized: "payment.bankTransfer")
            }
        }

        var iconName: String {
            switch self {
            case .applePay: return "apple.logo"
            case .creditCard: return "creditcard"
            case .cheque: return "doc.text"
            case .cashWithdrawal: return "banknote"
            case .bankTransfer: return "arrow.left.arrow.right"
            }
        }
        
        var color: Color {
            switch self {
            case .applePay: return .green
            case .creditCard: return .blue
            case .cheque: return .orange
            case .cashWithdrawal: return .yellow
            case .bankTransfer: return .red
            }
        }
    }

}

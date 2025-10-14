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
    var expenseCategory: ExpenseCategory? = nil
    /// True if this transaction is an internal transfer between accounts
    var isInternalTransfer: Bool = false

    init(
        title: String,
        transactionType: TransactionType,
        paymentMethod: PaymentMethod? = nil,
        expenseCategory: ExpenseCategory? = nil,
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
    
    enum ExpenseCategory: String, Codable, CaseIterable, Identifiable {
        case foodGroceries
        case diningOut
        case transportation
        case housing
        case utilities
        case insurance
        case healthcare
        case entertainment
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
            case .entertainment: return String(localized: "expense.entertainment") // Entertainment
            case .shopping: return String(localized: "expense.shopping") // Shopping
            case .education: return String(localized: "expense.education") // Education
            case .travel: return String(localized: "expense.travel") // Travel
            case .personalCare: return String(localized: "expense.personalCare") // Personal care
            case .subscriptions: return String(localized: "expense.subscriptions") // Subscriptions
            case .taxes: return String(localized: "expense.taxes") // Taxes
            case .debtPayment: return String(localized: "expense.debtPayment") // Debt & loan payments
            case .giftsDonations: return String(localized: "expense.giftsDonations") // Gifts & donations
            case .savingsInvestments: return String(localized: "expense.savingsInvestments") // Savings & investments
            case .other: return String(localized: "expense.other") // Other
            }
        }
        
        var iconName: String {
            switch self {
            case .foodGroceries: return "cart.fill"
            case .diningOut: return "fork.knife"
            case .transportation: return "car.fill"
            case .housing: return "house.fill"
            case .utilities: return "bolt.fill"
            case .insurance: return "shield.fill"
            case .healthcare: return "cross.case.fill"
            case .entertainment: return "film.fill"
            case .shopping: return "bag.fill"
            case .education: return "book.fill"
            case .travel: return "airplane"
            case .personalCare: return "figure.wave"
            case .subscriptions: return "play.rectangle.fill"
            case .taxes: return "banknote.fill"
            case .debtPayment: return "creditcard.fill"
            case .giftsDonations: return "gift.fill"
            case .savingsInvestments: return "chart.line.uptrend.xyaxis"
            case .other: return "ellipsis.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .foodGroceries: return .green
            case .diningOut: return .orange
            case .transportation: return .blue
            case .housing: return .brown
            case .utilities: return .yellow
            case .insurance: return .purple
            case .healthcare: return .red
            case .entertainment: return .pink
            case .shopping: return .mint
            case .education: return .teal
            case .travel: return .indigo
            case .personalCare: return .cyan
            case .subscriptions: return Color(red: 0.8, green: 1.0, blue: 0.0)
            case .taxes: return Color(red: 1.0, green: 0.84, blue: 0.0)
            case .debtPayment: return Color(red: 0.0, green: 0.5, blue: 0.0)
            case .giftsDonations: return Color(red: 1.0, green: 0.0, blue: 1.0)
            case .savingsInvestments: return Color(red: 0.6, green: 0.9, blue: 0.6)
            case .other: return .secondary
            }
        }
    }

}

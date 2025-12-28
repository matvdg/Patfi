import SwiftUI
import Foundation

extension Transaction {
    enum PaymentMethod: String, Codable, CaseIterable, Identifiable {
        case applePay
        case creditCard
        case cheque
        case cashWithdrawal
        case bankTransfer
        case directDebit
        
        var id: String { rawValue }
        
        var localized: String {
            switch self {
            case .applePay:
                return String(localized: "PaymentApplePay")
            case .creditCard:
                return String(localized: "PaymentCreditCard")
            case .cheque:
                return String(localized: "PaymentCheque")
            case .cashWithdrawal:
                return String(localized: "PaymentCashWithdrawal")
            case .bankTransfer:
                return String(localized: "PaymentBankTransfer")
            case .directDebit:
                return String(localized: "PaymentDirectDebit")
            }
        }
        
        var iconName: String {
            switch self {
            case .applePay: return "apple.logo"
            case .creditCard: return "creditcard"
            case .cheque: return "doc.text"
            case .cashWithdrawal: return "banknote"
            case .bankTransfer: return "arrow.left.arrow.right"
            case .directDebit: return "arrow.down"
            }
        }
        
        var color: Color {
            switch self {
            case .applePay: return .red
            case .creditCard: return .blue
            case .cheque: return .orange
            case .cashWithdrawal: return .yellow
            case .bankTransfer: return .green
            case .directDebit: return .purple
            }
        }
    }
}

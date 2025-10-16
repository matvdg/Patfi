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
                return String(localized: "payment.applePay")
            case .creditCard:
                return String(localized: "payment.creditCard")
            case .cheque:
                return String(localized: "payment.cheque")
            case .cashWithdrawal:
                return String(localized: "payment.cashWithdrawal")
            case .bankTransfer:
                return String(localized: "payment.bankTransfer")
            case .directDebit:
                return String(localized: "payment.directDebit")
            }
        }
        
        var iconName: String {
            switch self {
            case .applePay: return "apple.logo"
            case .creditCard: return "creditcard"
            case .cheque: return "doc.text"
            case .cashWithdrawal: return "banknote"
            case .bankTransfer: return "arrow.left.arrow.right.circle"
            case .directDebit: return "arrow.down.circle"
            }
        }
        
        var color: Color {
            switch self {
            case .applePay: return .green
            case .creditCard: return .blue
            case .cheque: return .orange
            case .cashWithdrawal: return .yellow
            case .bankTransfer: return .red
            case .directDebit: return .purple
            }
        }
    }
}

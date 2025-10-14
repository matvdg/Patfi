import Foundation
import SwiftUI
#if os(iOS)
import UIKit
#endif

enum QuickAction: String, Identifiable, CaseIterable {
    
    case expense  = "com.patfi.expense"
    case income   = "com.patfi.income"
    case transfer = "com.patfi.transfer"
    case balance  = "com.patfi.balance"
    case bank     = "com.patfi.bank"
    case account  = "com.patfi.account"
    
    var id: String { rawValue }
    
    public var localizedTitle: String {
        #if os(watchOS)
        return watchTitle
        #else
        return title
        #endif
    }
    
    var iconName: String {
        switch self {
        case .expense:
            return "minus.circle"
        case .income:
            return "plus.circle"
        case .transfer:
            return "arrow.left.arrow.right.circle"
        case .balance:
            return "dollarsign.circle"
        case .account:
            return "person.crop.circle.badge.plus"
        case .bank:
            return Bank.sfSymbol
        }
    }

    /// Indicates whether this action requires at least one existing account.
    var requiresAccount: Bool {
        switch self {
        case .expense, .income, .transfer, .balance:
            return true
        case .bank, .account:
            return false
        }
    }
    
    #if os(iOS)
    var shortcutItem: UIApplicationShortcutItem {
        UIApplicationShortcutItem(
            type: rawValue,
            localizedTitle: title,
            localizedSubtitle: nil,
            icon: UIApplicationShortcutIcon(systemImageName: iconName),
            userInfo: nil
        )
    }
    
    /// Returns the appropriate shortcut items for the current context.
    static var itemsForCurrentContext: [UIApplicationShortcutItem] {
        let hasAccount = !BalanceReader.totalBalance.isZero
        return QuickAction.allCases
            .filter { $0.requiresAccount == hasAccount }
            .map { $0.shortcutItem }
    }
    #endif
    
    private var title: String {
        switch self {
        case .bank:
            return String(localized: "addBank")
        case .account:
            return String(localized: "addAccount")
        case .income:
            return String(localized: "addIncome")
        case .expense:
            return String(localized: "addExpense")
        case .transfer:
            return String(localized: "addInternalTransfer")
        case .balance:
            return String(localized: "addBalance")
        }
    }
    
    private var watchTitle: String {
        switch self {
        case .bank:
            return String(localized: "bank")
        case .account:
            return String(localized: "account")
        case .income:
            return String(localized: "income")
        case .expense:
            return String(localized: "expense")
        case .transfer:
            return String(localized: "internalTransfer")
        case .balance:
            return String(localized: "balance")
        }
    }
    
    @ViewBuilder
    func destinationView(account: Account? = nil) -> some View {
        switch self {
        case .bank:
            EditBankView()
        case .account:
            AddAccountView()
        case .income:
            AddIncomeView(account: account)
        case .expense:
            AddExpenseView(account: account)
        case .transfer:
            AddInternalTransferView(sourceAccount: account)
        case .balance:
            AddBalanceView(account: account)
        }
    }
    
}

@Observable
class QuickActionCoordinator {
    
    var launchedQuickAction: QuickAction?
    
}

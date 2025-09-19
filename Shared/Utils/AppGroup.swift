import Foundation
import WidgetKit


enum AppGroup {
    static let id = "group.fr.matvdg.patfi"
    static let defaults = UserDefaults(suiteName: id)!
}

enum Keys {
    static let totalBalance = "totalBalance"
    static let balancesPerAccount = "balancesPerAccount"
    static let balancesPerCategory = "balancesPerCategory"
    static let balancesPerBank = "balancesPerBank"
}

struct BalanceReader {
    static func totalBalance() -> Double {
        return AppGroup.defaults.double(forKey: Keys.totalBalance)
    }
    
    static func balancesByAccount() -> [String: Double] {
        return AppGroup.defaults.dictionary(forKey: Keys.balancesPerAccount) as? [String: Double] ?? [:]
    }
    
    static func balancesByCategory() -> [String: Double] {
        return AppGroup.defaults.dictionary(forKey: Keys.balancesPerCategory) as? [String: Double] ?? [:]
    }
    
    static func balancesByBank() -> [[String: Any]] {
        return AppGroup.defaults.array(forKey: Keys.balancesPerBank) as? [[String: Any]] ?? []
    }
}

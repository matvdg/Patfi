import Foundation
import WidgetKit

let iCloudID = "iCloud.fr.matvdg.patfi"

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
    
    static var totalBalance: Double {
        AppGroup.defaults.double(forKey: Keys.totalBalance)
    }
    
    static var balancesByAccount: [String: Double] {
        AppGroup.defaults.dictionary(forKey: Keys.balancesPerAccount) as? [String: Double] ?? [:]
    }
    
    static var balancesByCategory: [String: Double] {
        AppGroup.defaults.dictionary(forKey: Keys.balancesPerCategory) as? [String: Double] ?? [:]
    }
    
    static var balancesByBank: [[String: Any]] {
        AppGroup.defaults.array(forKey: Keys.balancesPerBank) as? [[String: Any]] ?? []
    }
}

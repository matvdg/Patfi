import Foundation
import WidgetKit

enum AppIDs {
    static let appGroupID = "group.fr.matvdg.patfi"
    static var defaults: UserDefaults {
        UserDefaults(suiteName: appGroupID)!
    }
    static let iCloudID = "iCloud.fr.matvdg.patfi"
    
}

enum Keys {
    static let totalBalance = "totalBalance"
    static let balancesPerAccount = "balancesPerAccount"
    static let balancesPerCategory = "balancesPerCategory"
    static let balancesPerBank = "balancesPerBank"
}

struct BalanceReader {
    
    static var totalBalance: Double {
        AppIDs.defaults.double(forKey: Keys.totalBalance)
    }
    
    static var balancesByAccount: [String: Double] {
        AppIDs.defaults.dictionary(forKey: Keys.balancesPerAccount) as? [String: Double] ?? [:]
    }
    
    static var balancesByCategory: [String: Double] {
        AppIDs.defaults.dictionary(forKey: Keys.balancesPerCategory) as? [String: Double] ?? [:]
    }
    
    static var balancesByBank: [[String: Any]] {
        AppIDs.defaults.array(forKey: Keys.balancesPerBank) as? [[String: Any]] ?? []
    }
}

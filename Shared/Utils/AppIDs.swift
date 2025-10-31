import Foundation
import WidgetKit

enum AppIDs {
    static let appGroupID = "group.fr.matvdg.patfi"
    static var defaults: UserDefaults {
        UserDefaults(suiteName: appGroupID)!
    }
    static let iCloudID = "iCloud.fr.matvdg.patfiv3"
    
    static var twelveDataApiKey: String? {
        get {
            AppIDs.defaults.string(forKey: Keys.twelveDataApiKey)
        }
        set {
            AppIDs.defaults.set(newValue, forKey: Keys.twelveDataApiKey)
        }
    }
    
    static var lastMarketSyncUpdate: Date {
        get {
            if let date = AppIDs.defaults.object(forKey: Keys.lastMarketSyncUpdate) as? Date {
                return date
            } else {
                // Create it, next update in 12h
                AppIDs.defaults.set(Date.now, forKey: Keys.lastMarketSyncUpdate)
                return Date.now
            }
        }
        set {
            AppIDs.defaults.set(newValue, forKey: Keys.lastMarketSyncUpdate)
        }
    }
    
}

enum Keys {
    static let totalBalance = "totalBalance"
    static let balancesPerAccount = "balancesPerAccount"
    static let balancesPerCategory = "balancesPerCategory"
    static let balancesPerBank = "balancesPerBank"
    static let twelveDataApiKey = "twelveDataApiKey"
    static let lastMarketSyncUpdate = "lastMarketSyncUpdate"
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

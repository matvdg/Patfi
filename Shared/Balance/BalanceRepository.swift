import Foundation
import WidgetKit

class BalanceRepository {
    
    func groupByCategory(_ accounts: [Account]) -> [Category: [Account]] {
        Dictionary(grouping: accounts, by: { $0.category })
    }

    func groupByBank(_ accounts: [Account]) -> [Bank?: [Account]] {
        Dictionary(grouping: accounts, by: { $0.bank })
    }
    
    func balance(for accounts: [Account]) -> Double {
        let total = accounts.reduce(0) { $0 + ($1.latestBalance?.balance ?? 0) }
        return total
    }

    /// Persists balance information (total, per-account, per-category, per-bank) to AppGroup.defaults and reloads widget timelines.
    func update(accounts: [Account]) {
        let total = balance(for: accounts)
        print("ℹ️ Updated balances in AppGroup, total = \(total.toString)")
        
        let perAccount = balancesPerAccount(accounts: accounts)
        let perCategory = balancesPerCategory(accounts: accounts)
        let perBank = balancesPerBank(accounts: accounts)
        
        // Save to App Group UserDefaults
        let defaults = AppGroup.defaults
        defaults.set(total, forKey: Keys.totalBalance)
        defaults.set(perAccount, forKey: Keys.balancesPerAccount)
        defaults.set(perCategory, forKey: Keys.balancesPerCategory)
        defaults.set(perBank, forKey: Keys.balancesPerBank)
        
        // Reload widget timelines
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func balancesPerAccount(accounts: [Account]) -> [String: Double] {
        var result: [String: Double] = [:]
        for account in accounts {
            let name = "\(account.bank?.name ?? "") • \(account.name)"
            if let balance = account.latestBalance?.balance {
                result[name] = balance
            }
        }
        return result
    }
    
    private func balancesPerCategory(accounts: [Account]) -> [String: Double] {
        var result: [String: Double] = [:]
        for account in accounts {
            let category = account.category.rawValue
            if let balance = account.latestBalance?.balance {
                result[category, default: 0] += balance
            }
        }
        return result
    }

    private func balancesPerBank(accounts: [Account]) -> [String: Double] {
        var result: [String: Double] = [:]
        for account in accounts {
            if let bankName = account.bank?.name, let balance = account.latestBalance?.balance {
                result[bankName, default: 0] += balance
            }
        }
        return result
    }
    
    
    
}

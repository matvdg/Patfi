import Foundation
import WidgetKit

class BalanceRepository {
    
    func groupByCategory(_ accounts: [Account]) -> [Category: [Account]] {
        Dictionary(grouping: accounts, by: { $0.category })
    }

    func groupByBank(_ accounts: [Account]) -> [Bank: [Account]] {
        Dictionary(grouping: accounts, by: { $0.bank ?? Bank(name: "No bank", color: .gray) })
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

    private func balancesPerBank(accounts: [Account]) -> [[String: Any]] {
        // Aggregate balances by bank name to avoid requiring Bank to be Hashable
        var totalsByBankName: [String: Double] = [:]
        var representativeBankByName: [String: Bank] = [:]

        for account in accounts {
            let bankName = account.bank?.name ?? "Unknown Bank"
            if let balance = account.latestBalance?.balance {
                totalsByBankName[bankName, default: 0] += balance
            }
            // Keep a representative Bank instance per name (for color, etc.)
            if let bank = account.bank, representativeBankByName[bankName] == nil {
                representativeBankByName[bankName] = bank
            }
        }

        // Transform into array of dictionaries (bankName, total, colorPalette)
        let result: [[String: Any]] = totalsByBankName.map { (bankName, total) in
            let colorPalette: Any
            if let bank = representativeBankByName[bankName] {
                colorPalette = bank.color.rawValue
            } else {
                colorPalette = ""
            }
            return [
                "bankName": bankName,
                "total": total,
                "colorPalette": colorPalette
            ]
        }

        return result
    }
    
}

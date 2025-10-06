import Foundation
import WidgetKit
import SwiftData

class BalanceRepository {
    
    // MARK: - Series computation
    struct TotalPoint: Identifiable {
        let date: Date
        let total: Double
        let change: String
        var id: Double { date.timeIntervalSince1970 }
    }
    
    func generateSeries(for period: Period, from snapshots: [BalanceSnapshot]) -> [TotalPoint] {
        var cal = Calendar.current
        cal.timeZone = TimeZone.current
        let now = Date()
        var periods: [Date] = []
        for i in 0..<12 {
            switch period {
            case .days:
                if let date = cal.date(byAdding: .day, value: -i, to: cal.dateInterval(of: .day, for: now)!.end) {
                    periods.append(date)
                }
            case .weeks:
                if let date = cal.date(byAdding: .weekOfYear, value: -i, to: cal.dateInterval(of: .weekOfYear, for: now)!.end) {
                    periods.append(date)
                }
            case .months:
                if let date = cal.date(byAdding: .month, value: -i, to: cal.dateInterval(of: .month, for: now)!.end) {
                    periods.append(date)
                }
            case .years:
                if let date = cal.date(byAdding: .year, value: -i, to: cal.dateInterval(of: .year, for: now)!.end) {
                    periods.append(date)
                }
            }
        }

        let sortedPeriods = periods.sorted()

        // Prepare snapshots grouped by account and sorted by date ascending
        var snapshotsByAccount: [PersistentIdentifier: [(date: Date, value: Double)]] = [:]

        for snap in snapshots {
            guard let acc = snap.account else { continue }
            let day = cal.startOfDay(for: snap.date)
            snapshotsByAccount[acc.persistentModelID, default: []].append((day, snap.balance))
        }

        // Sort each account's snapshots by date ascending
        for key in snapshotsByAccount.keys {
            snapshotsByAccount[key]?.sort(by: { $0.date < $1.date })
        }

        var result: [TotalPoint] = []

        for (index, periodStart) in sortedPeriods.enumerated() {
            var total: Double = 0

            for (_, snaps) in snapshotsByAccount {
                // Find last snapshot before or at periodStart
                if let lastSnap = snaps.last(where: { $0.date <= periodStart }) {
                    total += lastSnap.value
                }
            }

            let change: String
            if index == 0 {
                change = "equal"
            } else {
                let prevTotal = result[index - 1].total
                if total > prevTotal {
                    change = "up"
                } else if total < prevTotal {
                    change = "down"
                } else {
                    change = "equal"
                }
            }

            result.append(TotalPoint(date: periodStart, total: total, change: change))
        }

        return result
    }
    
    func groupByCategory(_ accounts: [Account]) -> [Category: [Account]] {
        Dictionary(grouping: accounts, by: { $0.category })
    }

    func groupByBank(_ accounts: [Account]) -> [Bank: [Account]] {
        Dictionary(grouping: accounts, by: { $0.bank ?? Bank(name: "?", color: .gray, logoAvaibility: .optedOut) })
    }
    
    func balance(for accounts: [Account]) -> Double {
        let total = accounts.reduce(0) { $0 + ($1.latestBalance?.balance ?? 0) }
        return total
    }
    
    /// Returns all BalanceSnapshot from the given accounts, sorted by date ascending.
    func snapshots(for accounts: [Account]) -> [BalanceSnapshot] {
        let allSnapshots = accounts.flatMap { $0.balances ?? [] }
        return allSnapshots.sorted(by: { $0.date < $1.date })
    }

    /// Persists balance information (total, per-account, per-category, per-bank) to AppGroup.defaults and reloads widget timelines.
    func update(accounts: [Account]) {
        let total = balance(for: accounts)
        print("ℹ️ Updated balances in AppGroup, total = \(total.toString)")
        
        let perAccount = balancesPerAccount(accounts: accounts)
        let perCategory = balancesPerCategory(accounts: accounts)
        let perBank = balancesPerBank(accounts: accounts)
        
        // Save to App Group UserDefaults
        let defaults = AppIDs.defaults
        defaults.set(total, forKey: Keys.totalBalance)
        defaults.set(perAccount, forKey: Keys.balancesPerAccount)
        defaults.set(perCategory, forKey: Keys.balancesPerCategory)
        defaults.set(perBank, forKey: Keys.balancesPerBank)
        
        // Reload widget timelines
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    // MARK: - Private methods
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
        let grouped = groupByCategory(accounts)
        for (category, catAccounts) in grouped {
            result[category.rawValue] = balance(for: catAccounts)
        }
        return result
    }

    private func balancesPerBank(accounts: [Account]) -> [[String: Any]] {
        let grouped = groupByBank(accounts)
        let result: [[String: Any]] = grouped.map { (bank, bankAccounts) in
            return [
                "bankName": bank.name,
                "total": balance(for: bankAccounts),
                "colorPalette": bank.color.rawValue
            ]
        }
        return result
    }
    
}


enum Period: String, CaseIterable, Identifiable {
    case days, weeks, months, years
    var id: String { rawValue }
    var title: LocalizedStringResource {
        switch self {
        case .days: return "Days"
        case .weeks: return "Weeks"
        case .months: return "Months"
        case .years: return "Years"
        }
    }
}

enum Mode: String, CaseIterable, Identifiable {
    case categories, banks
    var id: String { rawValue }
    var title: LocalizedStringResource {
        switch self {
        case .categories: return "Categories"
        case .banks: return "Banks"
        }
    }
}

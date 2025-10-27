import Foundation
import WidgetKit
import SwiftData

class BalanceRepository {
    
    let accountRepository = AccountRepository()
    
    // MARK: - Series computation
    struct TotalPoint: Identifiable {
        let date: Date
        let total: Double
        let change: String
        var id: Double { date.timeIntervalSince1970 }
    }
    
    func add(amount: Double, date: Date, account: Account, context: ModelContext) {
        
        // Update current balance if necessary
        if date.isNow(for: .day) {
            account.currentBalance = amount
        }
        
        
        let dayStart = Calendar.current.startOfDay(for: date)

        // Compute day range for predicate-friendly filtering
        let endOfDay = Calendar.current.date(byAdding: DateComponents(day: 1, second: -1), to: dayStart) ?? dayStart

        // Fetch existing snapshot for the same day, then match account in-memory to avoid relationship comparison issues in predicates
        let fetchRequest = FetchDescriptor<BalanceSnapshot>(
            predicate: #Predicate { snap in
                snap.date >= dayStart && snap.date <= endOfDay
            }
        )

        let sameDaySnaps = (try? context.fetch(fetchRequest)) ?? []
        if let existingSnap = sameDaySnaps.first(where: { $0.account == account }) {
            existingSnap.balance = amount
        } else {
            let snap = BalanceSnapshot(date: dayStart, balance: amount, account: account)
            context.insert(snap)
        }

        try? context.save()
    }
    
    func updateWithTransaction(type: Transaction.TransactionType, amount: Double, account: Account, context: ModelContext) {
        let latestBalance = account.latestBalance
        let newBalance = type == .expense ? latestBalance - abs(amount) : latestBalance + abs(amount)
        add(amount: newBalance, date: Date(), account: account, context: context)
    }
    
    func generateSeries(for selectedPeriod: Period, selectedDate: Date, from snapshots: [BalanceSnapshot]) -> [TotalPoint] {
        if snapshots.isEmpty { return [] }
        var cal = Calendar.current
        cal.timeZone = TimeZone.current
        var selectedPeriods: [Date] = []
        for i in 0..<12 {
            switch selectedPeriod {
            case .day:
                if let date = cal.date(byAdding: .day, value: -i, to: selectedDate.normalizedDate(selectedPeriod: .day)) {
                    selectedPeriods.append(date)
                }
            case .week:
                if let date = cal.date(byAdding: .weekOfYear, value: -i, to: selectedDate.normalizedDate(selectedPeriod: .week)) {
                    selectedPeriods.append(date)
                }
            case .month:
                if let date = cal.date(byAdding: .month, value: -i, to: selectedDate.normalizedDate(selectedPeriod: .month)) {
                    selectedPeriods.append(date)
                }
            case .year: // 5 years otherwise slow because too many transactions
                guard i < 5 else { break }
                if let date = cal.date(byAdding: .year, value: -i, to: selectedDate.normalizedDate(selectedPeriod: .year)) {
                    selectedPeriods.append(date)
                }
            }
        }

        let sortedPeriods = selectedPeriods.sorted()

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

        for (index, selectedPeriodStart) in sortedPeriods.enumerated() {
            var total: Double = 0

            for (_, snaps) in snapshotsByAccount {
                // Find last snapshot before or at selectedPeriodStart
                if let lastSnap = snaps.last(where: { $0.date <= selectedPeriodStart }) {
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

            result.append(TotalPoint(date: selectedPeriodStart, total: total, change: change))
        }

        return result
    }
    
    func balance(for accounts: [Account]) -> Double {
        accounts.reduce(0) { $0 + $1.latestBalance }
    }

    /// Persists balance information (total, per-account, per-category, per-bank) to AppGroup.defaults and reloads widget timelines.
    func updateWidgets(accounts: [Account]) {
        let total = balance(for: accounts)
        print("ℹ️ Updated balances in AppGroup, total = \(total.currencyAmount)")
        
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
            result[name] = account.latestBalance
        }
        return result
    }
    
    private func balancesPerCategory(accounts: [Account]) -> [String: Double] {
        var result: [String: Double] = [:]
        let grouped = accountRepository.groupByCategory(accounts)
        for (category, catAccounts) in grouped {
            result[category.rawValue] = balance(for: catAccounts)
        }
        return result
    }

    private func balancesPerBank(accounts: [Account]) -> [[String: Any]] {
        let grouped = accountRepository.groupByBank(accounts)
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

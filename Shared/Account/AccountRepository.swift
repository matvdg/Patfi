import Foundation
import SwiftData

typealias AccountsPerCategory = [Category: [Account]]
typealias AccountsPerBank = [Bank: [Account]]

class AccountRepository {
    
    func groupByCategory(_ accounts: [Account]) -> AccountsPerCategory {
        Dictionary(grouping: accounts, by: { $0.category })
    }
    
    func groupByBank(_ accounts: [Account]) -> AccountsPerBank {
        Dictionary(grouping: accounts, by: { $0.bank ?? Bank(name: "?", color: .gray, logoAvaibility: .optedOut) })
    }
    
    func delete(account: Account, context: ModelContext) {
        context.delete(account)
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
    
    func create(name: String, balance: Double, category: Category, bank: Bank, context: ModelContext) {
        let account = Account(name: name, category: category, currentBalance: balance, bank: bank)
        context.insert(account)
        let snap = BalanceSnapshot(date: Date(), balance: balance, account: account)
        context.insert(snap)
        do { try context.save() } catch { print("Save error:", error) }
    }
    
    func setAsDefault(account: Account, context: ModelContext) {
        do {
            let allAccounts = try context.fetch(FetchDescriptor<Account>())
            for acc in allAccounts {
                acc.isDefault = false
            }
            account.isDefault = true
            try context.save()
        } catch {
            print("Error setting default account:", error)
        }
    }
    
    func unsetAsDefault(account: Account, context: ModelContext) {
        do {
            account.isDefault = false
            try context.save()
        } catch {
            print("Error setting default account:", error)
        }
    }
    
}

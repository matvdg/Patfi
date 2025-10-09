import Foundation
import SwiftData

class AccountRepository {
    
    func delete(account: Account, context: ModelContext) {
        context.delete(account)
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
    
    func create(name: String, balance: Double, category: Category, bank: Bank, context: ModelContext) {
        let account = Account(name: name, category: category, bank: bank)
        context.insert(account)
        let snap = BalanceSnapshot(date: Date(), balance: balance, account: account)
        context.insert(snap)
        do { try context.save() } catch { print("Save error:", error) }
    }
}

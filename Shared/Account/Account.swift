import Foundation
import SwiftData
import SwiftUI

@Model
final class Account: Identifiable {
    var name: String = ""
    var category: Category = Category.other
    
    @Relationship(inverse: \Bank.accounts)
    var bank: Bank? = nil
    
    @Relationship(deleteRule: .cascade, inverse: \BalanceSnapshot.account)
    var balances: [BalanceSnapshot]? = nil
    
    init(name: String = "", category: Category = Category.other, bank: Bank? = nil) {
        self.name = name
        self.category = category
        self.bank = bank
    }
    
    var latestBalance: BalanceSnapshot? {
        balances?.sorted { $0.date > $1.date }.first
    }
}

import Foundation
import SwiftData
import SwiftUI

@Model
final class Account {
    var name: String = ""
    var category: Category = Category.other
    
    @Relationship(deleteRule: .cascade, inverse: \BalanceSnapshot.account)
    var balances: [BalanceSnapshot]? = nil
    
    init(name: String = "", category: Category = Category.other) {
        self.name = name
        self.category = category
    }
    
    var latestBalance: BalanceSnapshot? {
        balances?.sorted { $0.date > $1.date }.first
    }
}

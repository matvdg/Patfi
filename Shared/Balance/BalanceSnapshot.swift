import Foundation
import SwiftData

@Model
final class BalanceSnapshot: Identifiable, Hashable {
    
    #Index<BalanceSnapshot>([\.date])
    
    var date: Date = Date()
    var balance: Double = 0.0
    var account: Account? = nil

    init(date: Date = Date(), balance: Double = 0.0, account: Account? = nil) {
        self.date = date
        self.balance = balance
        self.account = account
    }
}

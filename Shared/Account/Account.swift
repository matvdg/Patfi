import Foundation
import SwiftData
import SwiftUI

@Model
final class Account: Identifiable, Hashable {
    
    var name: String = ""
    var category: Category = Category.other
    var isDefault: Bool = false
    var currentBalance: Double?
    
    var isAsset: Bool {
        [.bonds, .crypto, .stocks, .commodities].contains(category)
    }
    
    @Relationship(inverse: \Bank.accounts)
    var bank: Bank? = nil
    
    @Relationship(deleteRule: .cascade)
    var asset: Asset? = nil
    
    @Relationship(deleteRule: .cascade, inverse: \BalanceSnapshot.account)
    var balances: [BalanceSnapshot]? = nil
    
    @Relationship(deleteRule: .cascade, inverse: \Transaction.account)
    var transactions: [Transaction]? = nil
    
    init(name: String = "", category: Category = Category.other, currentBalance: Double = 0, bank: Bank? = nil) {
        self.name = name
        self.category = category
        self.bank = bank
        self.currentBalance = currentBalance
    }
    
    var latestBalance: Double {
        if let currentBalance {
            return currentBalance
        }
        // Fallback if nil for before v2.0 without currentBalance (bad performance but just for once)
        let last = balances?.sorted(by: { $0.date > $1.date }).first?.balance ?? 0
        currentBalance = last
        return last
    }
}

@Model
final class Asset: Identifiable, Hashable {
    
    var name: String
    var quantity: Double
    var symbol: String
    var latestPrice: Double
    var totalInAssetCurrency: Double
    var totalInLocalCurrency: Double
    var currencySymbol: String

    @Relationship(inverse: \Account.asset)
    var account: Account? = nil

    init(name: String, quantity: Double, symbol: String, latestPrice: Double, totalInAssetCurrency: Double, totalInLocalCurrency: Double, currencySymbol: String, account: Account? = nil) {
        self.quantity = quantity
        self.symbol = symbol
        self.latestPrice = latestPrice
        self.totalInAssetCurrency = totalInAssetCurrency
        self.totalInLocalCurrency = totalInLocalCurrency
        self.account = account
        self.name = name
        self.currencySymbol = currencySymbol
    }
}

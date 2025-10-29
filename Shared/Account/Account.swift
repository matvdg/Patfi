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
    
    var name: String = ""
    var quantity: Double = 0
    var symbol: String = ""
    var exchange: String = ""
    var latestPrice: Double = 0
    var totalInAssetCurrency: Double = 0
    var totalInEuros: Double = 0
    var currencySymbol: String = ""
    var lastSyncDate: Date = Date()

    @Relationship(inverse: \Account.asset)
    var account: Account? = nil

    init(name: String, quantity: Double, symbol: String, exchange: String, latestPrice: Double, totalInAssetCurrency: Double, totalInEuros: Double, currencySymbol: String, account: Account? = nil) {
        self.quantity = quantity
        self.symbol = symbol
        self.latestPrice = latestPrice
        self.totalInAssetCurrency = totalInAssetCurrency
        self.totalInEuros = totalInEuros
        self.account = account
        self.name = name
        self.currencySymbol = currencySymbol
        self.lastSyncDate = Date()
        self.exchange = exchange
    }
    
    @MainActor func update(quantity: Double, euroDollarRate: Double, context: ModelContext) {
        guard self.currencySymbol == "$" else { return }
        self.quantity = quantity
        self.totalInAssetCurrency = quantity * latestPrice
        self.totalInEuros = totalInAssetCurrency / euroDollarRate
        self.lastSyncDate = Date()
        if let account = self.account {
            BalanceRepository().add(amount: totalInEuros, date: Date(), account: account, context: context)
        }
        do { try context.save() } catch { print("Save error:", error) }
    }
    
    @MainActor func update(latestPrice: Double, euroDollarRate: Double, context: ModelContext) {
        guard self.currencySymbol == "$" else { return }
        self.latestPrice = latestPrice
        self.totalInAssetCurrency = quantity * latestPrice
        self.totalInEuros = totalInAssetCurrency / euroDollarRate
        self.lastSyncDate = Date()
        if let account = self.account {
            BalanceRepository().add(amount: totalInEuros, date: Date(), account: account, context: context)
        }
        do { try context.save() } catch { print("Save error:", error) }
    }
}

@MainActor
let 🍏 = Asset(
    name: "Apple",
    quantity: 58.345036,
    symbol: "AAPL",
    exchange: "NASDAQ",
    latestPrice: 268.81,
    totalInAssetCurrency: 15683.72912716,
    totalInEuros: 13450.37,
    currencySymbol: "$"
)

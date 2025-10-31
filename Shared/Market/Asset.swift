import SwiftData
import Foundation

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

    @Relationship(deleteRule: .nullify, inverse: \Account.asset)
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

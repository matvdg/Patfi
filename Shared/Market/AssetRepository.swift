import Foundation
import SwiftData

class AssetRepository {
    
    private let balanceRepository = BalanceRepository()
    
    func delete(asset: Asset, context: ModelContext) {
        context.delete(asset)
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
    
    func create(close: Double, quantity: Double, euroDollarRate: Double, name: String, symbol: String, exchange: String, currencySymbol: String, account: Account, context: ModelContext) {
        let totalUSD = close * quantity
        let totalEUR = totalUSD / euroDollarRate
        let newAsset = Asset(name: name, quantity: quantity, symbol: symbol, exchange: exchange, latestPrice: close, totalInAssetCurrency: totalUSD, totalInEuros: totalEUR, currencySymbol: currencySymbol, account: account)
        context.insert(newAsset)
        account.asset = newAsset
        balanceRepository.add(amount: totalEUR, date: Date(), account: account, context: context)
        do { try context.save() } catch { print("Save error:", error) }
    }
    
    func update(asset: Asset, quantity: Double, euroDollarRate: Double, context: ModelContext) {
        guard asset.currencySymbol == "$" else { return }
        asset.quantity = quantity
        asset.totalInAssetCurrency = quantity * asset.latestPrice
        asset.totalInEuros = asset.totalInAssetCurrency / euroDollarRate
        asset.lastSyncDate = Date()
        if let account = asset.account {
            balanceRepository.add(amount: asset.totalInEuros, date: Date(), account: account, context: context)
        }
        do { try context.save() } catch { print("Save error:", error) }
    }
    
    func update(asset: Asset, newPrice: Double, euroDollarRate: Double, context: ModelContext) {
        guard asset.currencySymbol == "$" else { return }
        asset.latestPrice = newPrice
        asset.totalInAssetCurrency = asset.quantity * newPrice
        asset.totalInEuros = asset.totalInAssetCurrency / euroDollarRate
        asset.lastSyncDate = Date()
        if let account = asset.account {
            balanceRepository.add(amount: asset.totalInEuros, date: Date(), account: account, context: context)
        }
        do { try context.save() } catch { print("Save error:", error) }
    }
    
}

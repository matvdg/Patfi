import Foundation
import SwiftData

extension ModelContainer {
    
    @MainActor
    static func getSharedContainer() -> ModelContainer {
        let schema = Schema([Account.self, BalanceSnapshot.self, Bank.self])
        #if targetEnvironment(simulator)
        return ModelContainer.getSimulatorSharedContainer(schema: schema)
        #else
            // Check for iCloud availability
            let config: ModelConfiguration
            if FileManager.default.ubiquityIdentityToken != nil {
                // iCloud available → use CloudKit
                config = ModelConfiguration(schema: schema, cloudKitDatabase: .private(AppIDs.iCloudID))
            } else {
                // No iCloud → fallback to local store
                config = ModelConfiguration(schema: schema, cloudKitDatabase: .none)
            }
            do {
                return try ModelContainer(for: schema, configurations: [config])
            } catch {
                fatalError("Failed to load SwiftData ModelContainer: \(error)")
            }
        #endif
    }
    
    @MainActor
    static func getSimulatorSharedContainer(schema: Schema) -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        let container = try! ModelContainer(for: schema, configurations: [config])
        
        let boursoBank = Bank(name: "BoursoBank", color: .purple)
        let greenGot = Bank(name: "GreenGot", color: .green)
        let bnp = Bank(name: "BNP Paribas", color: .green)
        let crypto = Bank(name: "Crypto", color: .blue)
        let tradeRepublic = Bank(name: "Trade Republic", color: .gray)
        let revolut = Bank(name: "Revolut", color: .blue)
        let banks: [Bank] = [boursoBank, greenGot, bnp, crypto, tradeRepublic, revolut]
        banks.forEach { bank in
            container.mainContext.insert(bank)
        }
        
        let a1 = Account(name: "Livret A", category: .savings, bank: boursoBank)
        let a2 = Account(name: "LDD", category: .savings, bank: boursoBank)
        let a3 = Account(name: "CAV", category: .current, bank: greenGot)
        let a4 = Account(name: "GGPlanet", category: .lifeInsurance, bank: greenGot)
        let a5 = Account(name: "Bitcoins", category: .crypto, bank: crypto)
        let a6 = Account(name: "Gold", category: .commodities, bank: revolut)
        let a7 = Account(name: "PEA", category: .stocks, bank: bnp)
        let a8 = Account(name: " APL", category: .stocks, bank: tradeRepublic)
        
        let accounts: [Account] = [a1, a2, a3, a4, a5, a6, a7, a8]
        accounts.forEach { a in
            container.mainContext.insert(a)
        }
        
        let b1 = BalanceSnapshot(date: Date(), balance: Double.random(in: 10000...20000), account: a1)
        let b2 = BalanceSnapshot(date: Date(), balance: Double.random(in: 10000...20000), account: a2)
        let b3 = BalanceSnapshot(date: Date(), balance: Double.random(in: 10000...20000), account: a3)
        let b4 = BalanceSnapshot(date: Date(), balance: Double.random(in: 10000...20000), account: a4)
        let b5 = BalanceSnapshot(date: Date(), balance: Double.random(in: 10000...20000), account: a5)
        let b6 = BalanceSnapshot(date: Date(), balance: Double.random(in: 10000...20000), account: a6)
        let b7 = BalanceSnapshot(date: Date(), balance: Double.random(in: 10000...20000), account: a7)
        let b8 = BalanceSnapshot(date: Date(), balance: Double.random(in: 10000...20000), account: a8)
        let b9 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*31*2), balance: Double.random(in: 10000...20000), account: a8)
        let b10 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*31*15), balance: Double.random(in: 10000...20000), account: a8)
        
        let balances: [BalanceSnapshot] = [b1, b2, b3, b4, b5, b6, b7, b8, b9, b10]
        balances.forEach { b in
            container.mainContext.insert(b)
        }
        
        try! container.mainContext.save()

        return container
    }
    
    
}

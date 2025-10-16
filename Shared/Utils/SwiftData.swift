import Foundation
import SwiftData

extension ModelContainer {
    
    @MainActor
    static var shared: ModelContainer {
        let schema = Schema([Account.self, BalanceSnapshot.self, Bank.self, Transaction.self])
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
        
        /// Quick access to mock/empty data
        let mockDataEnabled = true
        
        if mockDataEnabled {
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
            a3.isDefault = true
            let a4 = Account(name: "GGPlanet", category: .lifeInsurance, bank: greenGot)
            let a5 = Account(name: "Bitcoins", category: .crypto, bank: crypto)
            let a6 = Account(name: "Gold", category: .commodities, bank: revolut)
            let a7 = Account(name: "PEA", category: .stocks, bank: bnp)
            let a8 = Account(name: " APL", category: .stocks, bank: tradeRepublic)
            
            let accounts: [Account] = [a1, a2, a3, a4, a5, a6, a7, a8]
            accounts.forEach { a in
                container.mainContext.insert(a)
            }
            
            /// 12 days balances
            for i in 0...12 {
                let days = TimeInterval(i)
                let b1 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*days), balance: Double.random(in: 10000...20000), account: a1)
                let b2 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*days), balance: Double.random(in: 10000...20000), account: a2)
                let b3 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*days), balance: Double.random(in: 10000...20000), account: a3)
                let b4 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*days), balance: Double.random(in: 10000...20000), account: a4)
                let b5 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*days), balance: Double.random(in: 10000...20000), account: a5)
                let b6 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*days), balance: Double.random(in: 10000...20000), account: a6)
                let b7 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*days), balance: Double.random(in: 10000...20000), account: a7)
                let b8 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*days), balance: Double.random(in: 10000...20000), account: a8)
                
                let balances: [BalanceSnapshot] = [b1, b2, b3, b4, b5, b6, b7, b8]
                balances.forEach { b in
                    container.mainContext.insert(b)
                }
            }
            
            /// 12 weeks balances
            for i in 0...12 {
                let days = TimeInterval(i*7+13)
                let b1 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*days), balance: Double.random(in: 10000...20000), account: a1)
                let b2 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*days), balance: Double.random(in: 10000...20000), account: a2)
                let b3 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*days), balance: Double.random(in: 10000...20000), account: a3)
                let b4 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*days), balance: Double.random(in: 10000...20000), account: a4)
                let b5 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*days), balance: Double.random(in: 10000...20000), account: a5)
                let b6 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*days), balance: Double.random(in: 10000...20000), account: a6)
                let b7 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*days), balance: Double.random(in: 10000...20000), account: a7)
                let b8 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*days), balance: Double.random(in: 10000...20000), account: a8)
                
                let balances: [BalanceSnapshot] = [b1, b2, b3, b4, b5, b6, b7, b8]
                balances.forEach { b in
                    container.mainContext.insert(b)
                }
            }
            
            /// 12 months balances
            for i in 0...12 {
                let days = TimeInterval(i*31+128)
                let b1 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*days), balance: Double.random(in: 10000...20000), account: a1)
                let b2 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*days), balance: Double.random(in: 10000...20000), account: a2)
                let b3 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*days), balance: Double.random(in: 10000...20000), account: a3)
                let b4 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*days), balance: Double.random(in: 10000...20000), account: a4)
                let b5 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*days), balance: Double.random(in: 10000...20000), account: a5)
                let b6 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*days), balance: Double.random(in: 10000...20000), account: a6)
                let b7 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*days), balance: Double.random(in: 10000...20000), account: a7)
                let b8 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*days), balance: Double.random(in: 10000...20000), account: a8)
                
                let balances: [BalanceSnapshot] = [b1, b2, b3, b4, b5, b6, b7, b8]
                balances.forEach { b in
                    container.mainContext.insert(b)
                }
            }
            
            /// 12 years balances
            for i in 0...12 {
                let days = TimeInterval(i*365+365)
                let b1 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*days), balance: Double.random(in: 10000...20000), account: a1)
                let b2 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*days), balance: Double.random(in: 10000...20000), account: a2)
                let b3 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*days), balance: Double.random(in: 10000...20000), account: a3)
                let b4 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*days), balance: Double.random(in: 10000...20000), account: a4)
                let b5 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*days), balance: Double.random(in: 10000...20000), account: a5)
                let b6 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*days), balance: Double.random(in: 10000...20000), account: a6)
                let b7 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*days), balance: Double.random(in: 10000...20000), account: a7)
                let b8 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*days), balance: Double.random(in: 10000...20000), account: a8)
                
                let balances: [BalanceSnapshot] = [b1, b2, b3, b4, b5, b6, b7, b8]
                balances.forEach { b in
                    container.mainContext.insert(b)
                }
            }
            
            /// 36  months transactions
            for i in 0...36 {
                let t = TimeInterval(-60*60*24*31*i)
                let day = TimeInterval(60*60*24)
                let t0 = Transaction(title: "Supermarket", transactionType: .expense, paymentMethod: .applePay, expenseCategory: .foodGroceries, date: Date().addingTimeInterval(t), amount: Double.random(in: 100...500), account: a3)
                let t1 = Transaction(title: "Travel", transactionType: .expense, paymentMethod: .applePay, expenseCategory: .travel, date: Date().addingTimeInterval(t-day), amount: Double.random(in: 1000...5000), account: a3)
                let t2 = Transaction(title: "Car fuel", transactionType: .expense, paymentMethod: .creditCard, expenseCategory: .transportation, date: Date().addingTimeInterval(t-day*2), amount: Double.random(in: 100...300), account: a3)
                let t3 = Transaction(title: "Rent", transactionType: .expense, paymentMethod: .bankTransfer, expenseCategory: .housing, date: Date().addingTimeInterval(t-day*4), amount: 800, account: a3)
                let t4 = Transaction(title: "Wage", transactionType: .income, paymentMethod: .bankTransfer, date: Date().addingTimeInterval(t-day*28), amount: 3000, account: a3)
                let t5 = Transaction(title: String(localized: "internalTransfer"), transactionType: .expense, paymentMethod: .bankTransfer, expenseCategory: nil, date: Date().addingTimeInterval(t-day*15), amount: 1000, account: a3, isInternalTransfer: true)
                let t6 = Transaction(title: String(localized: "internalTransfer"), transactionType: .income, paymentMethod: .bankTransfer, expenseCategory: nil, date: Date().addingTimeInterval(t-day*15), amount: 1000, account: a1, isInternalTransfer: true)
                let t7 = Transaction(title: "Bills", transactionType: .expense, paymentMethod: .directDebit, expenseCategory: .subscriptions, date: Date().addingTimeInterval(t-day*10), amount: Double.random(in: 100...200), account: a3)
                let t8 = Transaction(title: "Shopping", transactionType: .expense, paymentMethod: .cashWithdrawal, expenseCategory: .shopping, date: Date().addingTimeInterval(t-day*17), amount: Double.random(in: 100...500), account: a3)
                let t9 = Transaction(title: "Restaurants & bars", transactionType: .expense, paymentMethod: .creditCard, expenseCategory: .diningOut, date: Date().addingTimeInterval(t-day*22), amount: Double.random(in: 100...500), account: a3)
                let t10 = Transaction(title: "Doctor's visit", transactionType: .expense, paymentMethod: .cheque, expenseCategory: .healthcare, date: Date().addingTimeInterval(t-day*7), amount: Double.random(in: 20...200), account: a3)
                
                let transactions: [Transaction] = [t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10]
                transactions.forEach { t in
                    container.mainContext.insert(t)
                }
            }
            
        }
        
        try! container.mainContext.save()

        return container
    }
    
    
}

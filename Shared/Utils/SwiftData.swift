import Foundation
import SwiftData
import CloudKit

extension ModelContainer {
    
    @MainActor
    static let shared: ModelContainer = {
        //        if let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
        //            try? FileManager.default.removeItem(at: url)
        //            print("🧹 Local SwiftData store purged to force CloudKit zone recreation")
        //        }
        
        let schema = Schema([Account.self, BalanceSnapshot.self, Bank.self, Transaction.self, Asset.self, QuoteResponse.self])
        
        /// ⚠️ At least ONE launch on real device (real iPhone or Mac) in DEBUG before Prod to push Schemas changes -> then Deploy Schema Changes to Production on CloudKit console before Production!
        /// TO DO THAT set false BELOW ⬇️
#if (targetEnvironment(simulator) || DEBUG) && true
        // DEBUG = isStoredInMemoryOnly: true, cloudKitDatabase: .none with MOCK DATA
        return ModelContainer.getSimulatorSharedContainer(schema: schema)
#else
        let config: ModelConfiguration
        if FileManager.default.ubiquityIdentityToken != nil {
            // PRODUCTION = isStoredInMemoryOnly: false, cloudKitDatabase: .automatic
            config = ModelConfiguration(schema: schema, cloudKitDatabase: .automatic)
        } else {
            // If iCloud disabled OR if simulator - no iCloud (only on REAL devices)
            // DEBUG isStoredInMemoryOnly: false, cloudKitDatabase: .none without MOCK DATA
            config = ModelConfiguration(schema: schema, cloudKitDatabase: .none)
        }
        do {
            let container =  try ModelContainer(for: schema, configurations: [config])
            print("ℹ️ CloudKit container:", container.configurations.first!.cloudKitContainerIdentifier ?? "❌ none")
            return container
        } catch {
            fatalError("Failed to load SwiftData ModelContainer: \(error)")
        }
#endif
    }()
    
    @MainActor
    static func getSimulatorSharedContainer(schema: Schema) -> ModelContainer {
        
        /// Quick access to mock/empty data for DEBUG ONLY
        let mockDataEnabled = true
        
        let config = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        let container = try! ModelContainer(for: schema, configurations: [config])
        
        if mockDataEnabled {
            let boursoBank = Bank(name: "BoursoBank", color: .purple)
            let greenGot = Bank(name: "GreenGot", color: .green)
            let bnp = Bank(name: "BNP Paribas", color: .yellow)
            let crypto = Bank(name: "Crypto", color: .blue)
            let tradeRepublic = Bank(name: "Trade Republic", color: .gray)
            let revolut = Bank(name: "Revolut", color: .red)
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
            let a8 = Account(name: " Apple", category: .stocks, bank: tradeRepublic)
            let a9 = Account(name: "Prêt conso", category: .loan, bank: boursoBank)
            
            let accounts: [Account] = [a1, a2, a3, a4, a5, a6, a7, a8, a9]
            accounts.forEach { a in
                container.mainContext.insert(a)
            }
            
            let asset = Asset(name: "Apple", quantity: 10, symbol: "AAPL", exchange: "NASDAQ", latestPrice: 300, totalInAssetCurrency: 1000, totalInEuros: 900, currencySymbol: "$", account: a8)
            container.mainContext.insert(asset)
            
            let quoteResponse = QuoteResponse()
            quoteResponse.instrumentName = "Apple"
            quoteResponse.symbol = "AAPL"
            quoteResponse.exchange = "NASDAQ"
            container.mainContext.insert(quoteResponse)
            
            insertBalanceSnapshots(accounts: accounts, context: container.mainContext)
            insertTransactions(currentAccount: a3, savingAccount: a1, context: container.mainContext)
            
            func insertBalanceSnapshots(accounts: [Account], context: ModelContext) {
                let totalDays = 3650 // 10y
                var i = 0
                var iterationCount = 0
                while i <= totalDays {
                    for account in accounts {
                        let range = account.category == .loan ? -10000...0 : 10000...20000
                        let balance = Double.random(in: Double(range.lowerBound)...Double(range.upperBound))
                        let date = Date().addingTimeInterval(-60*60*24*Double(i))
                        let repo = BalanceRepository()
                        repo.add(amount: balance, date: date, account: account, context: context)
                    }
                    iterationCount += 1
                    switch i {
                    case 0..<30:
                        i += 1
                    case 30..<(30 + 8*7):
                        i += 7
                    case (30 + 8*7)..<(30 + 8*7 + 12*30):
                        i += 30
                    default:
                        i += 365
                    }
                }
            }
            
            func insertTransactions(currentAccount a3: Account, savingAccount a1: Account, context: ModelContext) {
                /// 36  months transactions
                for i in 0...36 {
                    let t = TimeInterval(-60*60*24*31*i)
                    let day = TimeInterval(60*60*24)
                    let t0 = Transaction(title: "Supermarket", transactionType: .expense, paymentMethod: .applePay, expenseCategory: .foodGroceries, date: Date().addingTimeInterval(t), amount: Double.random(in: 100...500), account: a3)
                    let t1 = Transaction(title: "Travel", transactionType: .expense, paymentMethod: .applePay, expenseCategory: .travel, date: Date().addingTimeInterval(t-day), amount: Double.random(in: 1000...5000), account: a3)
                    let t2 = Transaction(title: "Car fuel", transactionType: .expense, paymentMethod: .creditCard, expenseCategory: .transportation, date: Date().addingTimeInterval(t-day*2), amount: Double.random(in: 100...300), account: a3)
                    let t3 = Transaction(title: "Rent", transactionType: .expense, paymentMethod: .bankTransfer, expenseCategory: .housing, date: Date().addingTimeInterval(t-day*4), amount: 800, account: a3)
                    let t4 = Transaction(title: "Wage", transactionType: .income, paymentMethod: .bankTransfer, date: Date().addingTimeInterval(t-day*28), amount: 3000, account: a3)
                    let t5 = Transaction(title: String(localized: "InternalTransfer"), transactionType: .expense, paymentMethod: .bankTransfer, expenseCategory: .savingsInvestments, date: Date().addingTimeInterval(t-day*15), amount: 1000, account: a3, isInternalTransfer: true)
                    let t6 = Transaction(title: String(localized: "InternalTransfer"), transactionType: .income, paymentMethod: .bankTransfer, expenseCategory: nil, date: Date().addingTimeInterval(t-day*15), amount: 1000, account: a1, isInternalTransfer: true)
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
            
            do {
                try container.mainContext.save()
            }
            catch {
                print(error)
            }
        }
        return container
    }
}

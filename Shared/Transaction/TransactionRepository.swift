import Foundation
import SwiftData

class TransactionRepository {
    
    let balanceRepository = BalanceRepository()
    
    func addExpense(title: String,
                    amount: Double,
                    account: Account,
                    paymentMethod: Transaction.PaymentMethod,
                    expenseCategory: Transaction.ExpenseCategory,
                    date: Date,
                    context: ModelContext) {
        addTransaction(type: .expense,
                       title: title,
                       amount: amount,
                       account: account,
                       paymentMethod: paymentMethod,
                       isInternalTransfer: false,
                       expenseCategory: expenseCategory,
                       date: date,
                       context: context)
    }
    
    func addIncome(title: String,
                   amount: Double,
                   account: Account,
                   paymentMethod: Transaction.PaymentMethod,
                   date: Date,
                   context: ModelContext) {
        addTransaction(type: .income,
                       title: title,
                       amount: amount,
                       account: account,
                       paymentMethod: paymentMethod,
                       isInternalTransfer: false,
                       date: date,
                       context: context)
    }
    
    func addInternalTransfer(amount: Double,
                             sourceAccount: Account,
                             destinationAccount: Account,
                             date: Date,
                             context: ModelContext) {
        let title = String(localized: "internalTransfer")
        addTransaction(type: .expense,
                       title: title,
                       amount: amount,
                       account: sourceAccount,
                       paymentMethod: .bankTransfer,
                       isInternalTransfer: true,
                       date: date,
                       context: context)
        addTransaction(type: .income,
                       title: title,
                       amount: amount,
                       account: destinationAccount,
                       paymentMethod: .bankTransfer,
                       isInternalTransfer: true,
                       date: date,
                       context: context)
    }
    
    func groupByCategory(_ transactions: [Transaction]) -> [Transaction.ExpenseCategory: [Transaction]] {
        Dictionary(grouping: transactions, by: { $0.expenseCategory ?? .other })
    }
    
    func total(for transactions: [Transaction]) -> Double {
        transactions.reduce(0) { $0 + $1.amount }
    }
    
    private func addTransaction(type: Transaction.TransactionType,
                                title: String,
                                amount: Double,
                                account: Account,
                                paymentMethod: Transaction.PaymentMethod,
                                isInternalTransfer: Bool,
                                expenseCategory: Transaction.ExpenseCategory? = nil,
                                date: Date,
                                context: ModelContext) {
        let transaction = Transaction(
            title: title,
            transactionType: type,
            paymentMethod: paymentMethod,
            expenseCategory: expenseCategory,
            date: date,
            amount: abs(amount),
            account: account,
            isInternalTransfer: isInternalTransfer
        )
        context.insert(transaction)
        do {
            try context.save()
        } catch {
            print("Error saving transaction: \(error)")
        }
        
        // Update balance for the account
        guard let latestBalance = account.latestBalance?.balance else { return }
        let newBalance = type == .expense ? latestBalance - amount : latestBalance + amount
        balanceRepository.add(amount: newBalance, date: Date(), account: account, context: context)
    }
    
}

import Foundation
import SwiftData

typealias TransactionsPerCategory = [Transaction.ExpenseCategory: [Transaction]]
typealias TransactionsPerPaymentMethod = [Transaction.PaymentMethod: [Transaction]]
typealias TransactionsPerPeriod = [Date: [Transaction]]

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
    
    func addInternalTransfer(title: String,
                             amount: Double,
                             sourceAccount: Account,
                             destinationAccount: Account,
                             date: Date,
                             markAsDavingsInvestments: Bool,
                             context: ModelContext) {
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
                       expenseCategory: markAsDavingsInvestments ? .savingsInvestments : nil,
                       date: date,
                       context: context)
    }
    
    func groupByCategory(_ transactions: [Transaction]) -> TransactionsPerCategory {
        Dictionary(grouping: transactions, by: { $0.expenseCategory ?? .other })
    }
    
    func groupByPaymentMethod(_ transactions: [Transaction]) -> TransactionsPerPaymentMethod {
        Dictionary(grouping: transactions, by: { $0.paymentMethod })
    }
    
    func total(for transactions: [Transaction]) -> Double {
        transactions.reduce(0) { $0 + $1.amount }
    }
    
    func delete(_ transaction: Transaction, context: ModelContext) {
        context.delete(transaction)
        try? context.save()
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
        balanceRepository.updateWithTransaction(type: type, amount: amount, account: account, context: context)
    }
    
}

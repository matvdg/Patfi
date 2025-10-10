import Foundation
import SwiftData

class TransactionRepository {
    
    let balanceRepository = BalanceRepository()
    
    func addExpense(title: String,
                    amount: Double,
                    account: Account,
                    paymentMethod: Transaction.PaymentMethod,
                    expenseCategory: Transaction.ExpenseCategory,
                    context: ModelContext) {
        addTransaction(type: .expense,
                       title: title,
                       amount: amount,
                       account: account,
                       paymentMethod: paymentMethod,
                       isInternalTransfer: false,
                       expenseCategory: expenseCategory,
                       context: context)
    }
    
    func addIncome(title: String,
                   amount: Double,
                   account: Account,
                   context: ModelContext) {
        addTransaction(type: .income,
                       title: title,
                       amount: amount,
                       account: account,
                       paymentMethod: nil,
                       isInternalTransfer: false,
                       context: context)
    }
    
    func addInternalTransfer(title: String,
                             amount: Double,
                             sourceAccount: Account,
                             destinationAccount: Account,
                             context: ModelContext) {
        addTransaction(type: .expense,
                       title: title,
                       amount: amount,
                       account: sourceAccount,
                       paymentMethod: nil,
                       isInternalTransfer: true,
                       context: context)
        addTransaction(type: .income,
                       title: title,
                       amount: amount,
                       account: destinationAccount,
                       paymentMethod: nil,
                       isInternalTransfer: true,
                       context: context)
    }
    
    private func addTransaction(type: Transaction.TransactionType,
                                title: String,
                                amount: Double,
                                account: Account,
                                paymentMethod: Transaction.PaymentMethod?,
                                isInternalTransfer: Bool,
                                expenseCategory: Transaction.ExpenseCategory? = nil,
                                context: ModelContext) {
        let transaction = Transaction(
            title: title,
            transactionType: type,
            paymentMethod: paymentMethod,
            expenseCategory: expenseCategory,
            date: Date(),
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

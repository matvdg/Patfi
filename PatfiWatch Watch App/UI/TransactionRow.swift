import SwiftUI

struct TransactionRow: View {
    
    var transaction: Transaction
    
    var body: some View {
        
        HStack(alignment: .center, spacing: 8) {
            ExpenseCategoryLogo(cat: transaction.expenseCategory, isInternalTransfer: transaction.isInternalTransfer)
            VStack(alignment: .leading, spacing: 3) {
                Text(transaction.title)
                Text(transaction.date.toDateStyleShortString)
            }
            .font(.footnote)
            Spacer()
            AmountText(amount: transaction.transactionType == .expense ? -transaction.amount : transaction.amount)
                .font(.body)
                .bold()
                
        }
        .lineLimit(1)
        .minimumScaleFactor(0.1)
    }
}

#Preview {
    NavigationStack {
        List {
            TransactionRow(transaction: Transaction(title: "Carrefour", transactionType: .expense, paymentMethod: .applePay, expenseCategory: .foodGroceries, date: Date(), amount: 34.67))
            TransactionRow(transaction: Transaction(title: "Carrefour", transactionType: .expense, paymentMethod: .applePay, expenseCategory: .foodGroceries, date: Date(), amount: 34.67))
            TransactionRow(transaction: Transaction(title: "McDo", transactionType: .expense, paymentMethod: .creditCard, expenseCategory: .diningOut, date: Date(), amount: Double.random(in: 1...100)))
            TransactionRow(transaction: Transaction(title: "Rent", transactionType: .expense, paymentMethod: .creditCard, expenseCategory: .housing, date: Date(), amount: 800))
            TransactionRow(transaction: Transaction(title: "Shell", transactionType: .expense, paymentMethod: .creditCard, expenseCategory: .transportation, date: Date(), amount: Double.random(in: 1...100)))
            TransactionRow(transaction: Transaction(title: "Wage", transactionType: .income, paymentMethod: .bankTransfer, date: Date(), amount: 2100.29))
            TransactionRow(transaction: Transaction(title: String(localized: "internalTransfer"), transactionType: .expense, paymentMethod: .bankTransfer, expenseCategory: .savingsInvestments, date: Date(), amount: 1000, isInternalTransfer: true))
            TransactionRow(transaction: Transaction(title: String(localized: "internalTransfer"), transactionType: .income, paymentMethod: .bankTransfer, date: Date(), amount: 1000, isInternalTransfer: true))
            TransactionRow(transaction: Transaction(title: "EDF", transactionType: .expense, paymentMethod: .creditCard, expenseCategory: .utilities, date: Date(), amount: Double.random(in: 1...100)))
            TransactionRow(transaction: Transaction(title: "Macif", transactionType: .expense, paymentMethod: .creditCard, expenseCategory: .insurance, date: Date(), amount: Double.random(in: 1...100)))
            TransactionRow(transaction: Transaction(title: "Dentist", transactionType: .expense, paymentMethod: .creditCard, expenseCategory: .healthcare, date: Date(), amount: Double.random(in: 1...100)))
            TransactionRow(transaction: Transaction(title: "Cinema", transactionType: .expense, paymentMethod: .creditCard, expenseCategory: .entertainment, date: Date(), amount: Double.random(in: 1...100)))
            TransactionRow(transaction: Transaction(title: "GTA VII", transactionType: .expense, paymentMethod: .creditCard, expenseCategory: .gaming, date: Date(), amount: Double.random(in: 1...100)))
            TransactionRow(transaction: Transaction(title: "Basketball session", transactionType: .expense, paymentMethod: .creditCard, expenseCategory: .utilities, date: Date(), amount: Double.random(in: 1...100)))
            TransactionRow(transaction: Transaction(title: "Zara", transactionType: .expense, paymentMethod: .creditCard, expenseCategory: .shopping, date: Date(), amount: Double.random(in: 1...100)))
            TransactionRow(transaction: Transaction(title: "English class", transactionType: .expense, paymentMethod: .creditCard, expenseCategory: .education, date: Date(), amount: 2387.99))
            TransactionRow(transaction: Transaction(title: "🇮🇹 Italy trip", transactionType: .expense, paymentMethod: .creditCard, expenseCategory: .travel, date: Date(), amount: Double.random(in: 1...100)))
            TransactionRow(transaction: Transaction(title: "Hairdresser", transactionType: .expense, paymentMethod: .creditCard, expenseCategory: .personalCare, date: Date(), amount: Double.random(in: 1...100)))
            TransactionRow(transaction: Transaction(title: "Netflix", transactionType: .expense, paymentMethod: .creditCard, expenseCategory: .subscriptions, date: Date(), amount: Double.random(in: 1...100)))
            TransactionRow(transaction: Transaction(title: "Taxes", transactionType: .expense, paymentMethod: .creditCard, expenseCategory: .taxes, date: Date(), amount: Double.random(in: 1...100)))
            TransactionRow(transaction: Transaction(title: "Loan payment", transactionType: .expense, paymentMethod: .directDebit, expenseCategory: .debtPayment, date: Date(), amount: Double.random(in: 1...100)))
            TransactionRow(transaction: Transaction(title: "Greenpeace", transactionType: .expense, paymentMethod: .directDebit, expenseCategory: .giftsDonations, date: Date(), amount: Double.random(in: 1...100)))
            TransactionRow(transaction: Transaction(title: "Leo's launch", transactionType: .expense, paymentMethod: .directDebit, expenseCategory: .other, date: Date(), amount: Double.random(in: 1...100)))
        }
    }
}

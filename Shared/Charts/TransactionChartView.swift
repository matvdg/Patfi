import SwiftUI
import SwiftData
import Charts

struct TransactionChartView: View {
    
    let transactions: [Transaction]
    
    var body: some View {
        let totalIncome = transactions.filter { $0.transactionType == .income }.map(\.amount).reduce(0, +)
        let totalExpense = transactions.filter { $0.transactionType == .expense }.map(\.amount).reduce(0, +)
        let total = totalIncome - totalExpense
        let data: [(type: String, amount: Double, color: Color)] = [
            ("income", totalIncome, .green),
            ("expense", totalExpense, .red)
        ]
        
        VStack {
            Text("total")
            ColorAmount(amount: total).bold()
            
            Chart(data, id: \.type) { item in
                BarMark(
                    x: .value("amount", item.amount),
                    y: .value("", "")
                )
                .foregroundStyle(item.color)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .chartXAxisLabel("")
            .chartYAxisLabel("")
            .chartPlotStyle { plot in
                plot.frame(height: 40)
            }
            
            HStack {
                ColorAmount(amount: totalIncome).bold()
                Spacer()
                ColorAmount(amount: -totalExpense).bold()
            }
        }
        .padding()
    }
    
}

#Preview {
    VStack {
        let income = Transaction(title: "Wage", transactionType: .income, paymentMethod: .bankTransfer, date: Date(), amount: 2000, account: nil)
        let expense = Transaction(title: "Rent", transactionType: .expense, paymentMethod: .bankTransfer, expenseCategory: .housing, date: Date(), amount: 3800, account: nil)
        TransactionChartView(transactions: [income, expense])
        let income2 = Transaction(title: "Wage", transactionType: .income, paymentMethod: .bankTransfer, date: Date(), amount: 2000, account: nil)
        let expense2 = Transaction(title: "Rent", transactionType: .expense, paymentMethod: .bankTransfer, expenseCategory: .housing, date: Date(), amount: 2000, account: nil)
        TransactionChartView(transactions: [income2, expense2])
        let income3 = Transaction(title: "Wage", transactionType: .income, paymentMethod: .bankTransfer, date: Date(), amount: 5000, account: nil)
        let expense3 = Transaction(title: "Rent", transactionType: .expense, paymentMethod: .bankTransfer, expenseCategory: .housing, date: Date(), amount: 2000, account: nil)
        TransactionChartView(transactions: [income3, expense3])
    }
    
}

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
            Text(total.toString)
                .font(.headline)
                .foregroundColor(total >= 0 ? .green : .red)
            
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
                Text(totalIncome.toString)
                    .foregroundColor(.green)
                Spacer()
                Text(totalExpense.toString)
                    .foregroundColor(.red)
            }
        }
        .padding()
    }
    
}

#Preview {
    let income = Transaction(title: "Wage", transactionType: .income, paymentMethod: .bankTransfer, date: Date(), amount: 3000, account: nil)
    let expense = Transaction(title: "Rent", transactionType: .expense, paymentMethod: .bankTransfer, expenseCategory: .housing, date: Date(), amount: 3800, account: nil)
    TransactionChartView(transactions: [income, expense])
}

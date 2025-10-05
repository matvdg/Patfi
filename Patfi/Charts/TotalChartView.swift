import SwiftUI
import SwiftData
import Charts

struct TotalChartView: View {
    
    let snapshots: [BalanceSnapshot]

    @Binding var period: Period
    private let repo = BalanceRepository()

    var body: some View {
        
        let series = repo.generateSeries(for: period, from: snapshots)

        VStack(alignment: .center, spacing: 30) {

            if series.isEmpty {
                ContentUnavailableView(
                    "No data",
                    systemImage: "chart.line.uptrend.xyaxis",
                    description: Text("Add balances to see the graph")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                GeometryReader { geo in
                    Chart(series) { point in
                        BarMark(
                            x: .value("Date", point.date),
                            y: .value("Total", point.total),
                            width: .fixed(geo.size.width / 20)
                        )
                        .foregroundStyle(by: .value("Change", point.change))
                    }
                    .chartForegroundStyleScale([
                        "equal": .blue,
                        "up": .green,
                        "down": .red
                    ])
                    .chartLegend(.hidden)
                    .chartXAxis {
                        AxisMarks(values: .automatic(desiredCount: 12)) { value in
                            AxisGridLine()
                            AxisTick()
                            if let d = value.as(Date.self) {
                                switch period {
                                case .days:
                                    AxisValueLabel(format: .dateTime.day())
                                case .weeks:
                                    let weekOfYear = Calendar.current.component(.weekOfYear, from: d)
                                    AxisValueLabel {
                                        Text("W\(weekOfYear)").minimumScaleFactor(0.2)
                                    }
                                case .months:
                                    let month = Calendar.current.component(.month, from: d)
                                    AxisValueLabel {
                                        Text("\(month)").minimumScaleFactor(0.2)
                                    }
                                case .years:
                                    let year = Calendar.current.component(.year, from: d)
                                    AxisValueLabel {
                                        Text(String(format: "%02d", year % 100)).minimumScaleFactor(0.2)
                                    }
                                }
                            }
                        }
                    }
                    .chartYAxis(content: {
                        AxisMarks(position: .leading) { value in
                            AxisGridLine()
                            AxisTick()
                            if let v = value.as(Double.self) {
                                AxisValueLabel(v.toShortString)
                            }
                        }
                    })
                    .chartXAxis(.automatic)
                    .chartXScale(domain: .automatic, range: .plotDimension(startPadding: 20, endPadding: 20))
                    .frame(height: 260)
                }
            }
        }
        .padding()
    }

}

#Preview {
    let account = Account(name: "test", category: .savings, bank: nil)
    let b1 = BalanceSnapshot(date: Date(), balance: 100000, account: account)
    let b2 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*31*4), balance: 127650.55, account: account)
    let b3 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*31*15), balance: 1265.55, account: account)
    let b4 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*31*10), balance: 3000, account: account)
    let b5 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*31*9), balance: 10000, account: account)
    let b6 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*31*8), balance: 30000, account: account)
    let b7 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*31*7), balance: 100000, account: account)
    let b8 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*31*6), balance: 90000, account: account)
    let b9 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*31*5), balance: 100000, account: account)
    TotalChartView(snapshots: [b1, b2, b3, b4, b5, b6, b7, b8, b9], period: Binding<Period>(projectedValue: .constant(.months)))
}

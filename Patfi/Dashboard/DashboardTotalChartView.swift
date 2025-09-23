import SwiftUI
import SwiftData
import Charts

struct DashboardTotalChartView: View {
    
    let snapshots: [BalanceSnapshot]

    let repo = BalanceRepository()

    var body: some View {
        
        let series = repo.generateSeries(for: .months, from: snapshots)

        VStack(alignment: .leading, spacing: 30) {

            if series.isEmpty {
                ContentUnavailableView(
                    "No data",
                    systemImage: "chart.line.uptrend.xyaxis",
                    description: Text("Add balances to see the graph")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Chart(series) { point in
                    BarMark(
                        x: .value("Date", point.date),
                        y: .value("Total", point.total),
                        width: .fixed(15)
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
                            let month = Calendar.current.component(.month, from: d)
                            AxisValueLabel {
                                Text("\(month)").minimumScaleFactor(0.2)
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
        .padding()
    }

}

#Preview {
    DashboardTotalChartView(snapshots: [])
        .modelContainer(for: [Account.self, BalanceSnapshot.self], inMemory: true)
}

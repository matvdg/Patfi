import SwiftUI
import Charts
import SwiftData

struct TotalChartWidgetView: View {
    
    @Query(sort: \BalanceSnapshot.date, order: .forward) private var snapshots: [BalanceSnapshot]
    let repo = BalanceRepository()
    
    var body: some View {
        
        let series = repo.generateSeries(for: .months, from: snapshots)
        
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
                if let v = value.as(Double.self) {
                    AxisValueLabel(v.toShortString)
                }
            }
        })
        .chartXAxis(.automatic)
        .padding(.trailing, 20)
    }
}

#Preview {
    TotalChartWidgetView()
}

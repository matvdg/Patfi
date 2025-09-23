import SwiftUI
import SwiftData
import Charts

struct TotalChartView: View {
    
    @Binding var snapshots: [BalanceSnapshot]

    @State private var period: Period = .months
    let repo = BalanceRepository()

    var body: some View {
        
        let series = repo.generateSeries(for: period, from: snapshots)

        VStack(alignment: .leading, spacing: 30) {
            Picker("Range", selection: $period) {
                ForEach(Period.allCases) { p in
                    Text(p.title).tag(p)
                }
            }
            .pickerStyle(.segmented)

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
                        width: .fixed(20)
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
                            AxisValueLabel(v.toString)
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
    TotalChartView(snapshots: .constant([]))
        .modelContainer(for: [Account.self, BalanceSnapshot.self], inMemory: true)
}

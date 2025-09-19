import SwiftUI
import Charts

struct PieChartWidgetView: View {
    var body: some View {
        ZStack {
            Chart {
                ForEach(Array(BalanceReader.balancesByCategory.sorted { $0.key < $1.key }), id: \.key) { key, total in
                    let category = Category(rawValue: key) ?? .other
                    SectorMark(
                        angle: .value("Total", total),
                        innerRadius: .ratio(0.6),
                        angularInset: 1.0
                    )
                    .foregroundStyle(category.color)
                }
            }
            .chartLegend(.automatic)
        }
    }
}

#Preview {
    PieChartWidgetView()
}

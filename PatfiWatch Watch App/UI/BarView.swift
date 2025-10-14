import SwiftUI
import SwiftData

struct BarView: View {
    
    @State private var period: Period = .months
    @State private var showPeriodSheet = false
    @Query(sort: \BalanceSnapshot.date, order: .forward) private var snapshots: [BalanceSnapshot]
    
    var body: some View {
        Group {
            if snapshots.isEmpty {
                ContentUnavailableView(
                    "noData",
                    systemImage: "chart.bar",
                    description: Text("barChartEmptyDescription")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                TotalChartView(snapshots: snapshots, period: $period)
                    .toolbar {
                        ToolbarItem(placement: .bottomBar) {
                            Button {
                                showPeriodSheet = true
                            } label: {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                            }
                        }
                    }
                    .sheet(isPresented: $showPeriodSheet) {
                        PeriodView(period: $period)
                    }
            }
        }
        .navigationTitle("monitoring")
    }
    
}

#Preview {
    BarView()
        .modelContainer(ModelContainer.shared)
}

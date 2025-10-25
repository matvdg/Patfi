import SwiftUI
import SwiftData

struct BarView: View {
    
    @State private var period: Period = .months
    @State private var showPeriodSheet = false
    @Query(sort: \BalanceSnapshot.date, order: .forward) private var snapshots: [BalanceSnapshot]
    
    private let balanceRepository = BalanceRepository()
    
    private var balancesByPeriod: [BalanceRepository.TotalPoint] {
        balanceRepository.generateSeries(for: period, selectedDate: Date(), from: snapshots).sorted { $0.date > $1.date }
    }
    
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
                List {
                    BalanceChartView(snapshots: snapshots, period: period, selectedDate: Date())
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
                        .frame(height: 120)
                    ForEach(balancesByPeriod.enumerated(), id: \.element.id) { index, point in
                        HStack {
                            if index == 0 {
                                Text("now")
                            } else {
                                switch period {
                                case .weeks:
                                    let weekOfYear = Calendar.current.component(.weekOfYear, from: point.date)
                                    HStack {
                                        Text("w\(weekOfYear)").bold()
                                        Divider()
                                        Text(point.date.toDateStyleMediumString)
                                    }
                                case .months:
                                    let month = Calendar.current.component(.month, from: point.date)
                                    HStack {
                                        Text("\(month)").bold()
                                        Divider()
                                        Text(point.date.toDateStyleMediumString)
                                    }
                                default:
                                    Text(point.date.toDateStyleMediumString)
                                }
                            }
                            Divider()
                            AmountText(amount: point.total)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                        }
                    }
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

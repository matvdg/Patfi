import SwiftUI
import SwiftData
import Playgrounds

struct HomeMonitoringView: View {
    
    init(for period: Period, containing selectedDate: Date) {
        self.selectedDate = selectedDate
        self.period = period
        _snapshots = Query(filter: BalanceSnapshot.predicate(for: period, containing: selectedDate), sort: \.date, order: .reverse)
    }
    
    @Environment(\.modelContext) private var context
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Query(sort: \BalanceSnapshot.date, order: .forward) private var snapshots: [BalanceSnapshot]
    @State private var isGraphHidden = false
    private var selectedDate: Date = .now
    private var period: Period = .months
    
    private let balanceRepository = BalanceRepository()
    
    private var balancesByPeriod: [BalanceRepository.TotalPoint] {
        balanceRepository.generateSeries(for: period, selectedDate: selectedDate, from: snapshots).sorted { $0.date > $1.date }
    }
    
    private var isLandscape: Bool {
#if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .phone && verticalSizeClass == .compact
#else
        return false
#endif
    }
    
    var body: some View {
        Group {
            if snapshots.isEmpty {
                ContentUnavailableView(
                    "noData",
                    systemImage: "chart.bar",
                    description: Text("barChartEmptyDescription")
                )
            } else {
                VStack(alignment: .center) {
                    Group {
                        BalanceChartView(snapshots: snapshots, period: period, selectedDate: selectedDate)
                            .frame(maxHeight: .infinity)
                    }
                    .frame(height: isGraphHidden ? 0 : nil)
                    .opacity(isGraphHidden ? 0 : 1)
                    if !isLandscape {
                        ZStack {
                            ArrowButton(isUp: $isGraphHidden)
                        }
                        List {
                            ForEach(balancesByPeriod.enumerated(), id: \.element.id) { index, point in
                                HStack {
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
                                    Spacer()
                                    AmountText(amount: point.total).bold()
                                }
                            }
                        }
                    }
                }
                .onChange(of: isLandscape, {
                    isGraphHidden = false
                })
            }
        }
        .navigationTitle("monitoring")
    }
}

#Preview {
    HomeMonitoringView(for: .months, containing: Date())
        .modelContainer(ModelContainer.shared)
}

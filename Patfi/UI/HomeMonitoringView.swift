import SwiftUI
import SwiftData
import Playgrounds

struct HomeMonitoringView: View {
    
    init(for selectedPeriod: Period, containing selectedDate: Date) {
        self.selectedDate = selectedDate
        self.selectedPeriod = selectedPeriod
        _snapshots = Query(filter: BalanceSnapshot.predicate(for: selectedPeriod, containing: selectedDate), sort: \.date, order: .reverse)
    }
    
    @Environment(\.modelContext) private var context
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Query private var snapshots: [BalanceSnapshot]
    @State private var isGraphHidden = false
    private var selectedDate: Date
    private var selectedPeriod: Period
    
    private let balanceRepository = BalanceRepository()
    
    private var balancesByPeriod: [BalanceRepository.TotalPoint] {
        balanceRepository.generateSeries(for: selectedPeriod, selectedDate: selectedDate, from: snapshots).sorted { $0.date > $1.date }
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
                    "NoData",
                    systemImage: "chart.bar",
                    description: Text("DescriptionEmptyBarChart")
                )
            } else {
                VStack(alignment: .center) {
                    Group {
                        BalanceChartView(snapshots: snapshots, selectedPeriod: selectedPeriod, selectedDate: selectedDate)
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
                                    HStack {
                                        let isNow = point.date.isNow(for: selectedPeriod)
                                        selectedPeriod == .week ?
                                        Text("W\(point.date.getComponent(for: selectedPeriod))").bold()
                                        : Text("\(selectedPeriod == .week ? "w" : "")\(point.date.getComponent(for: selectedPeriod))").bold()
                                        Divider()
                                        if isNow {
                                            Text("Now").bold()
                                        } else {
                                            Text(point.date.toDateStyleMediumString)
                                        }
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
        .navigationTitle("Monitoring")
    }
}

#Preview {
    TabView {
        HomeMonitoringView(for: .day, containing: Date().normalizedDate(selectedPeriod: .day))
            .modelContainer(ModelContainer.shared)
        HomeMonitoringView(for: .week, containing: Date().normalizedDate(selectedPeriod: .week))
            .modelContainer(ModelContainer.shared)
        HomeMonitoringView(for: .month, containing: Date().normalizedDate(selectedPeriod: .month))
            .modelContainer(ModelContainer.shared)
        HomeMonitoringView(for: .year, containing: Date().normalizedDate(selectedPeriod: .year))
            .modelContainer(ModelContainer.shared)
    }
    .tabViewStyle(.page)
}

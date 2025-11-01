import SwiftUI
import SwiftData

struct MonitoringView: View {
    
    init(for selectedPeriod: Period, containing selectedDate: Date, account: Account? = nil) {
        self.selectedDate = selectedDate
        self.selectedPeriod = selectedPeriod
        self.account = account
        _snapshots = Query(filter: BalanceSnapshot.predicate(for: selectedPeriod, containing: selectedDate), sort: \.date, order: .reverse)
    }
    
    @Environment(\.modelContext) private var context
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Query private var snapshots: [BalanceSnapshot]
    @State private var isGraphHidden = false
    
    private var selectedDate: Date
    private var selectedPeriod: Period
    private var account: Account?
    
    private let balanceRepository = BalanceRepository()
    
    private var balancesByPeriod: [BalanceRepository.TotalPoint] {
        balanceRepository.generateSeries(for: selectedPeriod, selectedDate: selectedDate, from: filteredSnapshots).sorted { $0.date > $1.date }
    }
    
    private var filteredSnapshots: [BalanceSnapshot] {
        var filteredSnapshots: [BalanceSnapshot] = snapshots
        if let account {
            filteredSnapshots = filteredSnapshots.filter { $0.account?.id == account.id }
        }
        return filteredSnapshots
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
            if filteredSnapshots.isEmpty {
                VStack {
                    ContentUnavailableView(
                        "NoData",
                        systemImage: "chart.bar",
                        description: Text("DescriptionEmptyBarChart")
                    )
                    Spacer()
                }
            } else {
#if os(watchOS)
                List {
                    BalanceChartView(snapshots: filteredSnapshots, selectedPeriod: selectedPeriod, selectedDate: selectedDate)
                        .frame(height: 120)
                    BalancesByPeriodView(balancesByPeriod: balancesByPeriod, selectedPeriod: selectedPeriod)
                }
#else
                VStack(alignment: .center) {
                    BalanceChartView(snapshots: filteredSnapshots, selectedPeriod: selectedPeriod, selectedDate: selectedDate)
                            .frame(height: 300)
                    .frame(height: isGraphHidden ? 0 : nil)
                    .opacity(isGraphHidden ? 0 : 1)
                    if !isLandscape {
                        ZStack {
                            ArrowButton(isUp: $isGraphHidden)
                        }
                        List {
                            BalancesByPeriodView(balancesByPeriod: balancesByPeriod, selectedPeriod: selectedPeriod)
                        }
                    }
                }
                .onChange(of: isLandscape, {
                    isGraphHidden = false
                })
#endif
            }
        }
        .navigationTitle("Monitoring")
    }
}

struct BalancesByPeriodView: View {
    
    var balancesByPeriod: [BalanceRepository.TotalPoint]
    var selectedPeriod: Period
    
    var body: some View {
        ForEach(Array(balancesByPeriod.enumerated()), id: \.element.id) { index, point in
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
                .lineLimit(2)
#if os(watchOS)
                Divider()
#else
                Spacer()
#endif
                AmountText(amount: point.total)
                    .bold()
            }
            .lineLimit(1)
            .minimumScaleFactor(0.5)
        }
    }
}

#Preview {
    TabView {
        MonitoringView(for: .day, containing: Date().normalizedDate(selectedPeriod: .day))
            .modelContainer(ModelContainer.shared)
        MonitoringView(for: .week, containing: Date().normalizedDate(selectedPeriod: .week))
            .modelContainer(ModelContainer.shared)
        MonitoringView(for: .month, containing: Date().normalizedDate(selectedPeriod: .month))
            .modelContainer(ModelContainer.shared)
        MonitoringView(for: .year, containing: Date().normalizedDate(selectedPeriod: .year))
            .modelContainer(ModelContainer.shared)
    }
#if !os(macOS)
    .tabViewStyle(.page)
#endif
}

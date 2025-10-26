import SwiftUI
import SwiftData

struct MonitoringView: View {
    
    @State private var selectedDate: Date = .now
    @State private var selectedPeriod: Period = .month
    
    var body: some View {
        VStack {
            TwelvePeriodPicker(selectedDate: $selectedDate, selectedPeriod: $selectedPeriod)
            BarView(for: selectedPeriod, containing: selectedDate)
        }
        .onAppear {
            selectedDate = selectedDate.normalizedDate(selectedPeriod: selectedPeriod)
        }
    }
}

struct BarView: View {
    
    @Query private var snapshots: [BalanceSnapshot]
    
    private let balanceRepository = BalanceRepository()
    
    private var balancesByPeriod: [BalanceRepository.TotalPoint] {
        balanceRepository.generateSeries(for: selectedPeriod, selectedDate: selectedDate, from: snapshots).sorted { $0.date > $1.date }
    }
    
    private var selectedDate: Date
    private var selectedPeriod: Period
    
    @Environment(\.modelContext) private var context
    
    init(for selectedPeriod: Period, containing selectedDate: Date) {
        self.selectedDate = selectedDate
        self.selectedPeriod = selectedPeriod
        _snapshots = Query(filter: BalanceSnapshot.predicate(for: selectedPeriod, containing: selectedDate), sort: \.date, order: .reverse)
    }
    
    var body: some View {
        Group {
            if snapshots.isEmpty {
                ContentUnavailableView(
                    "NoData",
                    systemImage: "chart.bar",
                    description: Text("DescriptionEmptyBarChart")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    BalanceChartView(snapshots: snapshots, selectedPeriod: selectedPeriod, selectedDate: selectedDate)
                        .frame(height: 120)
                    ForEach(balancesByPeriod.enumerated(), id: \.element.id) { index, point in
                        HStack {
                            if index == 0 {
                                Text("Now")
                            } else {
                                switch selectedPeriod {
                                case .week:
                                    let weekOfYear = Calendar.current.component(.weekOfYear, from: point.date)
                                    HStack {
                                        Text("W\(weekOfYear)").bold()
                                        Divider()
                                        Text(point.date.toDateStyleMediumString)
                                    }
                                case .month:
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
        .navigationTitle("Monitoring")
    }
    
}

#Preview {
    MonitoringView()
        .modelContainer(ModelContainer.shared)
}

import SwiftUI
import SwiftData
import Playgrounds

struct HomeMonitoringView: View {
    
    @Environment(\.modelContext) private var context
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Query(sort: \BalanceSnapshot.date, order: .forward) private var snapshots: [BalanceSnapshot]
    @State private var isGraphHidden = false
    var period: Period
    
    private let balanceRepository = BalanceRepository()
    
    private var balancesByPeriod: [BalanceRepository.TotalPoint] {
        balanceRepository.generateSeries(for: period, from: snapshots).sorted { $0.date > $1.date }
    }
    
    private var isLandscape: Bool {
#if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .phone && verticalSizeClass == .compact
#else
        return false
#endif
    }
    
    var body: some View {
        
        VStack(alignment: .center) {
            Group {
                BalanceChartView(snapshots: snapshots, period: period)
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
                                    if index == 0 {
                                        Text("now")
                                    } else {
                                        switch period {
                                        case .days:
                                            Text(point.date.toString)
                                        case .weeks:
                                            let weekOfYear = Calendar.current.component(.weekOfYear, from: point.date)
                                            HStack {
                                                Text("w\(weekOfYear)").bold()
                                                Divider()
                                                Text(point.date.toString)
                                            }
                                        case .months:
                                            let month = Calendar.current.component(.month, from: point.date)
                                            HStack {
                                                Text("\(month)").bold()
                                                Divider()
                                                Text(point.date.toString)
                                            }
                                        case .years:
                                            let year = Calendar.current.component(.year, from: point.date)
                                            HStack {
                                                Text(String(format: "%02d", year % 100)).bold()
                                                Divider()
                                                Text(point.date.toString)
                                            }
                                        }
                                    }
                                    Spacer()
                                    ColorAmount(amount: point.total).bold()
                                }
                            }
                    }
                    .navigationTitle("monitoring")
                }
                
        }
        .onChange(of: isLandscape, {
            isGraphHidden = false
        })
    }
}

#Preview {
    HomeMonitoringView(period: .months)
        .modelContainer(ModelContainer.shared)
}

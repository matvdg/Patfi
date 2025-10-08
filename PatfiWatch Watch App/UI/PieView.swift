import SwiftUI
import SwiftData

struct PieView: View {
    
    @Query(sort: \Account.name, order: .forward) private var accounts: [Account]
    @State private var mode: Mode = .categories
    @State private var showModeSheet = false
    private let repo = BalanceRepository()
    
    var body: some View {
        Group {
            if accounts.isEmpty {
                ContentUnavailableView(
                    "No data",
                    systemImage: "chart.pie",
                    description: Text("Add balances to see distribution")
                )
            } else {
                List {
                    PieChartView(grouping: $mode)
                    switch mode {
                    case .banks:
                        let sorted = repo.groupByBank(accounts)
                            .map {
                                ($0.key, repo.balance(for: $0.value))
                            }
                            .sorted { $0.1 > $1.1 }
                        
                        ForEach(sorted, id: \.0) { bank, total in
                            NavigationLink {
                                ColorView(bank: bank)
                            } label: {
                                HStack {
                                    HStack(spacing: 8) {
                                        Circle().fill(bank.swiftUIColor).frame(width: 10, height: 10)
                                        Text(bank.name)
                                    }
                                    Spacer()
                                    Text(total.toString)
                                }
                                .lineLimit(1)
                                .minimumScaleFactor(0.1)
                            }
                        }
                    case .categories:
                        let sorted = repo.groupByCategory(accounts)
                            .map {
                                ($0.key, repo.balance(for: $0.value))
                            }
                            .sorted { $0.1 > $1.1 }
                        
                        ForEach(sorted, id: \.0) { cat, total in
                            HStack {
                                HStack(spacing: 8) {
                                    Circle().fill(cat.color).frame(width: 10, height: 10)
                                    Text(cat.localized)
                                }
                                Spacer()
                                Text(total.toString)
                            }
                            .lineLimit(1)
                            .minimumScaleFactor(0.1)
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        Button {
                            showModeSheet = true
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                        }
                    }
                }
                .sheet(isPresented: $showModeSheet) {
                    ModeView(mode: $mode)
                }
            }
        }
        .navigationTitle("Distribution")
    }
}

#Preview {
    PieView()
        .modelContainer(ModelContainer.getSharedContainer())
}

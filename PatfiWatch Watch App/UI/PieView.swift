import SwiftUI
import SwiftData

struct PieView: View {
    
    @Query(sort: \Account.name, order: .forward) private var accounts: [Account]
    @State private var mode: WatchMode = .categories
    @State private var showModeSheet = false
    @State private var selectedMonth: Date = .now
    private let balanceRepository = BalanceRepository()
    private let accountRepository = AccountRepository()
    private let transactionRepository = TransactionRepository()
    
    var body: some View {
        Group {
            if accounts.isEmpty {
                ContentUnavailableView(
                    "noData",
                    systemImage: "chart.pie",
                    description: Text("pieChartEmptyDescription")
                )
            } else {
                List {
                    switch mode {
                    case .banks:
                        PieChartView(accounts: accounts, transactions: [], grouping: .accounts, sortByBank: true)
                        let sorted = accountRepository.groupByBank(accounts)
                            .map {
                                ($0.key, balanceRepository.balance(for: $0.value))
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
                        PieChartView(accounts: accounts, transactions: [], grouping: .accounts, sortByBank: false)
                        let sorted = accountRepository.groupByCategory(accounts)
                            .map {
                                ($0.key, balanceRepository.balance(for: $0.value))
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
                    default:
                        MonthPicker(selectedMonth: $selectedMonth)
                        ExpensesView(selectedMonth: selectedMonth, sortByPaymentMethod: mode == .paymentMethod)
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
        .navigationTitle("distribution")
    }
}

#Preview {
    NavigationStack {
        PieView()
            .modelContainer(ModelContainer.shared)
    }
}

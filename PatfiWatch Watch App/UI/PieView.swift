import SwiftUI
import SwiftData

struct PieView: View {
    
    @Query(sort: \Account.name, order: .forward) private var accounts: [Account]
    @State private var mode: WatchMode = .categories
    @State private var showModeSheet = false
    @State private var selectedDate: Date = .now
    @State private var selectedPeriod: Period = .month
    private let balanceRepository = BalanceRepository()
    private let accountRepository = AccountRepository()
    private let transactionRepository = TransactionRepository()
    
    var body: some View {
        Group {
            if accounts.isEmpty {
                ContentUnavailableView(
                    "NoData",
                    systemImage: "chart.pie",
                    description: Text("DescriptionEmptyPieChart")
                )
            } else {
                List {
                    switch mode {
                    case .banks:
                        PieChartView(accounts: accounts, transactions: [], grouping: .accounts, sortByBank: true)
                            .toolbar {
                                ToolbarItem(placement: .bottomBar) {
                                    Button {
                                        showModeSheet = true
                                    } label: {
                                        Image(systemName: "line.3.horizontal.decrease.circle")
                                    }
                                }
                            }
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
                                    AmountText(amount: total)
                                }
                                .lineLimit(1)
                                .minimumScaleFactor(0.1)
                            }
                        }
                    case .categories:
                        PieChartView(accounts: accounts, transactions: [], grouping: .accounts, sortByBank: false)
                            .toolbar {
                                ToolbarItem(placement: .bottomBar) {
                                    Button {
                                        showModeSheet = true
                                    } label: {
                                        Image(systemName: "line.3.horizontal.decrease.circle")
                                    }
                                }
                            }
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
                                AmountText(amount: total)
                            }
                            .lineLimit(1)
                            .minimumScaleFactor(0.1)
                        }
                    default:
                        PeriodPicker(selectedDate: $selectedDate, selectedPeriod: $selectedPeriod)
                            .toolbar {
                                ToolbarItem(placement: .bottomBar) {
                                    Button {
                                        showModeSheet = true
                                    } label: {
                                        Image(systemName: "line.3.horizontal.decrease.circle")
                                    }
                                }
                            }
                        ExpensesView(selectedDate: selectedDate, selectedPeriod: selectedPeriod, sortByPaymentMethod: mode == .paymentMethod)
                    }
                }
            }
        }
        .sheet(isPresented: $showModeSheet) {
            ModeView(mode: $mode)
        }
        .navigationTitle("Distribution")
    }
}

#Preview {
    NavigationStack {
        PieView()
            .modelContainer(ModelContainer.shared)
    }
}

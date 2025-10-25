import SwiftUI
import SwiftData
import Playgrounds

struct HomeView: View {
    
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    @Query(sort: \Account.name, order: .forward) private var accounts: [Account]
    @State private var showAddAccount = false
    @State private var selectedChart = 0
    @State var mode: Mode = .accounts
    @State private var selectedDate: Date = .now
    @State private var period: Period = .months
    
    private let accountRepository = AccountRepository()
    private let balanceRepository = BalanceRepository()
    
    private var isLandscape: Bool {
#if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .phone && verticalSizeClass == .compact
#else
        return false
#endif
    }
    
    var body: some View {
        
        VStack(alignment: .center) {
            if accounts.isEmpty {
                ContentUnavailableView {
                    Image(systemName: "creditcard")
                } description: {
                    Text("noAccounts")
                } actions: {
                    Button {
                        showAddAccount = true
                    } label: {
                        Label("createAccount", systemImage: "plus")
                            .padding()
                    }
#if os(visionOS)
                    .buttonStyle(.borderedProminent)
#else
                    .buttonStyle(.glassProminent)
#endif
                }
            } else {
                if !isLandscape {
                    Picker("", selection: $selectedChart) {
#if os(macOS)
                        Text(selectedChart == 0 ? "􀜋 \(String(localized: "distribution"))" : "􀑀 \(String(localized: "distribution"))").tag(0)
                        Text(selectedChart == 1 ? "􀐿 \(String(localized: "monitoring"))" : "􀐾 \(String(localized: "monitoring"))").tag(1)
                        Text(selectedChart == 2 ? "􂷽 \(String(localized: "transactions"))" : "􂷼 \(String(localized: "transactions"))").tag(2)
#else
                        Image(systemName: selectedChart == 0 ? "chart.pie.fill" : "chart.pie").tag(0)
                        Image(systemName: selectedChart == 1 ? "chart.bar.fill" : "chart.bar").tag(1)
                        Image(systemName: selectedChart == 2 ? "receipt.fill" : "receipt").tag(2)
#endif
                    }
                    .pickerStyle(.segmented)
                    .controlSize(.extraLarge)
                    .frame(width: 150)
                    Group {
                        if selectedChart == 0 {
                            Picker("", selection: $mode) {
                                ForEach(Mode.allCases) { mode in
                                    Text(mode.localized).tag(mode)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding()
                        } else if selectedChart == 1 {
                            TwelvePeriodPicker(selectedDate: $selectedDate, period: $period)
                        }
                    }
                }
                
                switch selectedChart {
                case 0: // Distribution (PieChart by Category/Bank for accounts and ExpenseCategory/PaymentMethod for expenses)
                    switch mode {
                    case .accounts: HomeAccountsView()
                    case .expenses: HomeExpensesView()
                    }
                case 1: // Monitoring (Balances BarChart)
                    HomeMonitoringView(for: period, containing: selectedDate)
                default: // Transactions (Incomes/expenses BarChart)
                    HomeTransactionsView()
                }
            }
        }
        .onChange(of: scenePhase) { old, newPhase in
            print("ℹ️ \(scenePhase)")
            balanceRepository.updateWidgets(accounts: accounts)
        }
#if os(macOS)
        .padding()
#endif
        .ignoresSafeArea(edges: .bottom)
        
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Menu {
                    ForEach(QuickAction.allCases, id: \.self) { action in
                        // If there are no accounts, skip actions that require an account
                        if accounts.isEmpty && action.requiresAccount {
                            // Skip
                        } else {
                            NavigationLink {
                                action.destinationView()
                            } label: {
                                Label(action.localizedTitle, systemImage: action.iconName)
                            }
                        }
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .navigationDestination(isPresented: $showAddAccount) {
            AddAccountView()
        }
#if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
}

#Preview {
    HomeView()
        .modelContainer(ModelContainer.shared)
}

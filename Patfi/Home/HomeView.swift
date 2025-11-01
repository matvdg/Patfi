import SwiftUI
import SwiftData
import Playgrounds

struct HomeView: View {
    
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.modelContext) private var context

    @Query(sort: \Account.name, order: .forward) private var accounts: [Account]
    @State private var showAddAccount = false
    @State private var showMarketSearch = false
    @State private var selectedChart = 0
    @State var mode: Mode = .accounts
    @State private var selectedDate: Date = .now
    @State private var selectedPeriod: Period = .month
    @AppStorage("isBetaEnabled") private var isBetaEnabled = false
    @State private var showBetaBadge = false
    
    private let accountRepository = AccountRepository()
    private let balanceRepository = BalanceRepository()
    private let marketRepository = MarketRepository()
    
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
                    Text("NoAccounts")
                } actions: {
                    Button {
                        showAddAccount = true
                    } label: {
                        Label("CreateAccount", systemImage: "plus")
                            .padding()
                    }
                    .modifier(ButtonStyleModifier(isProminent: true))
                }
            } else {
                if !isLandscape {
                    Picker("", selection: $selectedChart) {
#if os(macOS)
                        Text(selectedChart == 0 ? "􀜋 \(String(localized: "Distribution"))" : "􀑀 \(String(localized: "Distribution"))").tag(0)
                        Text(selectedChart == 1 ? "􀐿 \(String(localized: "Monitoring"))" : "􀐾 \(String(localized: "Monitoring"))").tag(1)
                        Text(selectedChart == 2 ? "􂷽 \(String(localized: "Transactions"))" : "􂷼 \(String(localized: "Transactions"))").tag(2)
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
                            TwelvePeriodPicker(selectedDate: $selectedDate, selectedPeriod: $selectedPeriod)
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
                    MonitoringView(for: selectedPeriod, containing: selectedDate)
                        .onAppear {
                            selectedDate = selectedDate.normalizedDate(selectedPeriod: selectedPeriod)
                        }
                default: // Transactions (Incomes/expenses BarChart)
                    HomeTransactionsView()
                }
            }
        }
        .onChange(of: scenePhase) { old, newPhase in
            print("ℹ️ \(scenePhase)")
            if scenePhase == .background {
                balanceRepository.updateWidgets(accounts: accounts)
            }
            if scenePhase == .active {
                print("ℹ️ lastMarketSyncUpdate = \(AppIDs.lastMarketSyncUpdate)")
                marketRepository.updateAccountsIfMarketSync(accounts: accounts, context: context)
            }
        }
#if os(macOS)
        .padding()
#endif
        .ignoresSafeArea(edges: .bottom)
        .overlay(alignment: .topLeading) {
            ZStack {
                Color.clear
                    .frame(width: 60, height: 60)
                    .contentShape(Rectangle())
                    .onTapGesture(count: 3) {
                        if #available(iOS 26, *) {
                            isBetaEnabled.toggle()
                            print("🧪 Beta mode toggled → \(isBetaEnabled)")
#if os(iOS)
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
#endif
                            withAnimation {
                                showBetaBadge = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    showBetaBadge = false
                                }
                            }
                        }
                    }
                if showBetaBadge {
                    BetaBadge()
                    #if !os(macOS)
                        .padding(.top, -20)
                    #endif
                }
            }
        }
        .toolbar {
            if isBetaEnabled {
                ToolbarItem(placement: .automatic) {
                    Button {
                        showMarketSearch = true
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }
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
                    if #available(iOS 26, *) {
                        Image(systemName: "plus")
                    } else {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                    }
                }
            }
        }
        .navigationDestination(isPresented: $showAddAccount) {
            AddAccountView()
        }
        .navigationDestination(isPresented: $showMarketSearch) {
            MarketSearchView(account: nil)
        }
#if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .modelContainer(ModelContainer.shared)
}

import SwiftUI
import SwiftData
import Playgrounds

struct HomeView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    @Query(sort: \Account.name, order: .forward) private var accounts: [Account]
    @Query(sort: \BalanceSnapshot.date, order: .forward) private var snapshots: [BalanceSnapshot]
    @State private var showAddAccount = false
    @State private var selectedChart = 0
    @State var mode: Mode = .categories
    @State var period: Period = .months
    @State private var isGraphHidden = false
    @State private var collapsedSections: Set<String> = []
    
    private var allKeys: [String] {
        switch mode {
            // TODO
        case .expenses:
            accountsByCategory.map { $0.key.localized }
        case .categories:
            accountsByCategory.map { $0.key.localized }
        case .banks:
            accountsByBank.map { $0.key.normalizedName }
        }
    }
    
    private var allCollapsed: Bool {
        collapsedSections.count == allKeys.count
    }
    
    private var allCollapsedBinding: Binding<Bool> {
        Binding(
            get: {
                allCollapsed },
            set: { newValue in
                if newValue {
                    collapsedSections = Set(allKeys)
                } else {
                    collapsedSections.removeAll()
                }
            }
        )
    }
    
    private let balanceRepository = BalanceRepository()
    private let transactionRepository = TransactionRepository()
    
    private var accountsByCategory: [Dictionary<Category, [Account]>.Element] {
        Array(balanceRepository.groupByCategory(accounts).sorted { $0.key.localized < $1.key.localized })
            .sorted {
                balanceRepository.balance(for: $0.value) > balanceRepository.balance(for: $1.value)
            }
    }
    
    private var accountsByBank: [Dictionary<Bank, [Account]>.Element] {
        Array(balanceRepository.groupByBank(accounts).sorted { $0.key.normalizedName < $1.key.normalizedName })
            .sorted {
                balanceRepository.balance(for: $0.value) > balanceRepository.balance(for: $1.value)
            }
    }
    
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
                        Text(selectedChart == 0 ? "transactions" : "transactions").tag(0)
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
                }
                Group {
                    if selectedChart == 0 {
                        Picker("", selection: $mode) {
                            ForEach(Mode.allCases) { mode in
                                Text(mode.localized).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding()
                    } else {
                        Picker("", selection: $period) {
                            ForEach(Period.allCases) { period in
                                Text(period.localized).tag(period)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding()
                    }
                }
                Group {
                    if selectedChart == 0 {
                        PieChartView(grouping: $mode)
                    } else {
                        TotalChartView(snapshots: snapshots, period: $period)
                            .frame(maxHeight: .infinity)
                    }
                }
                .frame(height: isGraphHidden ? 0 : nil)
                .opacity(isGraphHidden ? 0 : 1)
                if !isLandscape {
                    ZStack {
                        ArrowButton(isUp: $isGraphHidden)
                        if selectedChart == 0 {
                            HStack {
                                Spacer()
                                CollapseButton(isCollapsed: allCollapsedBinding).padding(.trailing, 12)
                            }
                        }
                    }
                    List {
                        if selectedChart == 0 {
                            switch mode {
                                // TODO
                            case .expenses:
                                ForEach(accountsByCategory, id: \.key) { (category, items) in
                                    let isCollapsed = collapsedSections.contains(category.localized)
                                    Section {
                                        if !isCollapsed {
                                            ForEach(items) { account in
                                                NavigationLink { AccountDetailView(account: account) } label: { AccountRow(account: account) }
                                            }
                                        }
                                    } header: {
                                        ArrowRightButton(isRight: Binding(
                                            get: { isCollapsed },
                                            set: { isCollapsed in
                                                if isCollapsed {
                                                    collapsedSections.insert(category.localized)
                                                } else {
                                                    collapsedSections.remove(category.localized)
                                                }
                                            }
                                        )) {
                                            HStack(spacing: 8) {
                                                Circle().fill(category.color).frame(width: 10, height: 10)
                                                Text(category.localized)
                                                Spacer()
                                                Text(balanceRepository.balance(for: items).toString)
                                            }
                                        }
                                        .frame(height: isCollapsed ? 5 : 30)
                                        .padding(.top, isCollapsed ? 12 : 0)
#if os(macOS)
                                        .padding(.vertical, 8)
                                        .frame(height: 50)
#endif
                                    }
                                }
                            case .categories:
                                ForEach(accountsByCategory, id: \.key) { (category, items) in
                                    let isCollapsed = collapsedSections.contains(category.localized)
                                    Section {
                                        if !isCollapsed {
                                            ForEach(items) { account in
                                                NavigationLink { AccountDetailView(account: account) } label: { AccountRow(account: account) }
                                            }
                                        }
                                    } header: {
                                        ArrowRightButton(isRight: Binding(
                                            get: { isCollapsed },
                                            set: { isCollapsed in
                                                if isCollapsed {
                                                    collapsedSections.insert(category.localized)
                                                } else {
                                                    collapsedSections.remove(category.localized)
                                                }
                                            }
                                        )) {
                                            HStack(spacing: 8) {
                                                Circle().fill(category.color).frame(width: 10, height: 10)
                                                Text(category.localized)
                                                Spacer()
                                                Text(balanceRepository.balance(for: items).toString)
                                            }
                                        }
                                        .frame(height: isCollapsed ? 5 : 30)
                                        .padding(.top, isCollapsed ? 12 : 0)
#if os(macOS)
                                        .padding(.vertical, 8)
                                        .frame(height: 50)
#endif
                                    }
                                }
                            case .banks:
                                ForEach(accountsByBank, id: \.key) { (bank, items) in
                                    let isCollapsed = collapsedSections.contains(bank.normalizedName)
                                    Section {
                                        if !isCollapsed {
                                            ForEach(items) { account in
                                                NavigationLink { AccountDetailView(account: account) } label: { AccountRow(account: account, displayBankLogo: false) }
                                            }
                                        } else {
                                            EmptyView().frame(height: 100)
                                        }
                                    } header: {
                                        ArrowRightButton(isRight: Binding(
                                            get: { isCollapsed },
                                            set: { isCollapsed in
                                                if isCollapsed {
                                                    collapsedSections.insert(bank.normalizedName)
                                                } else {
                                                    collapsedSections.remove(bank.normalizedName)
                                                }
                                            }
                                        )) {
                                            HStack {
                                                BankRow(bank: bank)
                                                Spacer()
                                                Text(balanceRepository.balance(for: items).toString)
                                            }
                                        }
                                        .frame(height: isCollapsed ? 22 : 30)
                                        .padding(.top, isCollapsed ? 4 : 0)
#if os(macOS)
                                        .padding(.vertical, 8)
                                        .frame(height: 50)
#endif
                                    }
                                }
                            }
                        } else {
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
                                                Text("w\(weekOfYear)")
                                                Text("•  \(point.date.toString)")
                                            }
                                        case .months:
                                            let month = Calendar.current.component(.month, from: point.date)
                                            HStack {
                                                Text("\(month)")
                                                Text("•  \(point.date.toString)")
                                            }
                                        case .years:
                                            let year = Calendar.current.component(.year, from: point.date)
                                            HStack {
                                                Text(String(format: "%02d", year % 100))
                                                Text("•  \(point.date.toString)")
                                            }
                                        }
                                    }
                                    Spacer()
                                    Text(point.total.toString)
                                }
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
#if os(macOS)
                    .listStyle(.plain)
                    .padding()
#else
                    .listStyle(.insetGrouped)
#endif
                }
            }
        }
        .onChange(of: scenePhase) { old, newPhase in
            print("ℹ️ \(scenePhase)")
            balanceRepository.update(accounts: accounts)
        }
        .onChange(of: isLandscape, {
            isGraphHidden = false
        })
        .onChange(of: mode) { _, _ in
            collapsedSections = []
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
        .navigationTitle("patfi")
        
#if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
}

#Preview {
    HomeView()
        .modelContainer(ModelContainer.shared)
}

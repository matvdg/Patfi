import SwiftUI
import SwiftData
import Playgrounds
import WidgetKit

struct HomeView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    @Query(sort: \Account.name, order: .forward) private var accounts: [Account]
    @Query(sort: \BalanceSnapshot.date, order: .forward) private var snapshots: [BalanceSnapshot]
    @State private var showingAddAccount = false
    @State private var selectedChart = 0
    @State var mode: Mode = .categories
    @State var period: Period = .months
    @State private var isGraphHidden = false
    
    private let repo = BalanceRepository()
        
    private var accountsByCategory: [Dictionary<Category, [Account]>.Element] {
        Array(repo.groupByCategory(accounts).sorted { $0.key.localizedCategory < $1.key.localizedCategory })
            .sorted {
                repo.balance(for: $0.value) > repo.balance(for: $1.value)
            }
    }
    
    private var accountsByBank: [Dictionary<Bank, [Account]>.Element] {
        Array(repo.groupByBank(accounts).sorted { $0.key.normalizedName < $1.key.normalizedName })
            .sorted {
                repo.balance(for: $0.value) > repo.balance(for: $1.value)
            }
    }
    
    private var balancesByPeriod: [BalanceRepository.TotalPoint] {
        repo.generateSeries(for: period, from: snapshots).sorted { $0.date > $1.date }
    }
    
    private var isLandscape: Bool {
            #if os(iOS)
            return UIDevice.current.userInterfaceIdiom == .phone && verticalSizeClass == .compact
            #else
            return false
            #endif
        }
    
    var body: some View {
        
        NavigationStack {
            VStack(alignment: .center) {
                if accounts.isEmpty {
                    ContentUnavailableView("No accounts", systemImage: "creditcard")
                } else {
                    if !isLandscape {
                        Picker("", selection: $selectedChart) {
#if os(macOS)
                            Text(selectedChart == 0 ? "􀜋 \(String(localized: "Distribution"))" : "􀑀 \(String(localized: "Distribution"))").tag(0)
                            Text(selectedChart == 1 ? "􀐿 \(String(localized: "Monitoring"))" : "􀐾 \(String(localized: "Monitoring"))").tag(1)
#else
                            Image(systemName: selectedChart == 0 ? "chart.pie.fill" : "chart.pie").tag(0)
                            Image(systemName: selectedChart == 1 ? "chart.bar.fill" : "chart.bar").tag(1)
#endif
                        }
                        .pickerStyle(.segmented)
                        .controlSize(.extraLarge)
                        .frame(width: 100)
                    }
                    Group {
                        if selectedChart == 0 {
                            Picker("", selection: $mode) {
                                ForEach(Mode.allCases) { mode in
                                    Text(mode.title).tag(mode)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding()
                        } else {
                            Picker("", selection: $period) {
                                ForEach(Period.allCases) { period in
                                    Text(period.title).tag(period)
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
                        ArrowButton(isUp: $isGraphHidden)
                        List {
                            if selectedChart == 0 {
                                switch mode {
                                case .categories:
                                    ForEach(accountsByCategory, id: \.key) { (category, items) in
                                        Section {
                                            ForEach(items) { account in
                                                NavigationLink { AccountDetailView(account: account) } label: { AccountRow(account: account) }
                                            }
                                        } header: {
                                            VStack(alignment: .center, spacing: 8) {
                                                Spacer()
                                                HStack(spacing: 8) {
                                                    Circle().fill(category.color).frame(width: 10, height: 10)
                                                    Text(category.localizedName)
                                                    Spacer()
                                                    Text(repo.balance(for: items).toString)
                                                }
#if os(macOS)
                                                .padding(.vertical, 8)
#endif
                                            }
#if os(macOS)
                                            .frame(height: 50)
#endif
                                        }
                                    }
                                case .banks:
                                    ForEach(accountsByBank, id: \.key) { (bank, items) in
                                        Section {
                                            ForEach(items) { account in
                                                NavigationLink { AccountDetailView(account: account) } label: { AccountRow(account: account, displayBankLogo: false) }
                                            }
                                        } header: {
                                            VStack(alignment: .center, spacing: 8) {
                                                Spacer()
                                                HStack {
                                                    BankRow(bank: bank)
                                                    Spacer()
                                                    Text(repo.balance(for: items).toString)
                                                }
#if os(macOS)
                                                .padding(.vertical, 8)
#endif
                                            }
#if os(macOS)
                                            .frame(height: 50)
#endif
                                        }
                                    }
                                }
                            } else {
                                ForEach(balancesByPeriod.enumerated(), id: \.element.id) { index, point in
                                    HStack {
                                        if index == 0 {
                                            Text("Now")
                                        } else {
                                            switch period {
                                            case .days:
                                                Text(point.date.toString)
                                            case .weeks:
                                                let weekOfYear = Calendar.current.component(.weekOfYear, from: point.date)
                                                HStack {
                                                    Text("W\(weekOfYear)")
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
            #if os(macOS)
            .padding()
            #endif
            .ignoresSafeArea(edges: .bottom)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: { showingAddAccount = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationDestination(isPresented: $showingAddAccount) {
                AddAccountView()
            }
            .navigationTitle("Patfi")
            
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
        .onChange(of: scenePhase) { old, newPhase in
            print("ℹ️ \(scenePhase)")
            repo.update(accounts: accounts)
        }
        .onChange(of: isLandscape, {
            isGraphHidden = false
        })
    }
}

#Preview {
    HomeView()
        .modelContainer(ModelContainer.getSharedContainer())
}

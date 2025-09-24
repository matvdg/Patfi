import SwiftUI
import SwiftData
import Playgrounds
import WidgetKit
import TipKit

struct AccountsDashboardView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase

    @Query(sort: \Account.name, order: .forward) private var accounts: [Account]
    @Query(sort: \BalanceSnapshot.date, order: .forward) private var snapshots: [BalanceSnapshot]
    @State private var showingAddAccount = false
    @State private var selectedChart = 0
    
    let repo = BalanceRepository()
    
    var body: some View {
        
        NavigationStack {
#if os(iOS) || os(tvOS)
            ZStack(alignment: .bottomTrailing) {
                VStack(alignment: .leading) {
                    if !repo.balance(for: accounts).isZero {
                        let dashboardTip = DashboardTip()
                        TabView {
                            Section {
                                NavigationLink {
                                    VStack {
                                        PieChartView()
                                        Spacer()
                                    }
                                } label: {
                                    DashboardPieChartView()
                                }
                            }
                            Section {
                                NavigationLink {
                                    VStack {
                                        TotalChartView(snapshots: snapshots)
                                        Spacer()
                                    }
                                } label: {
                                    VStack(alignment: .center, spacing: 20) {
                                        DashboardTotalChartView(snapshots: snapshots)
                                            .frame(height: 300)
                                        Spacer()
                                    }
                                }
                            }
                        }
                        
                        .tabViewStyle(.page)
                        .indexViewStyle(.page(backgroundDisplayMode: .always))
                        .popoverTip(dashboardTip, arrowEdge: .top)
                    }
                    
                    if accounts.isEmpty {
                        ContentUnavailableView("No accounts", systemImage: "creditcard")
                    } else {
                        List {
                            let groups = repo.groupByCategory(accounts).sorted {
                                $0.key.localizedCategory < $1.key.localizedCategory
                            }
                            ForEach(Array(groups), id: \.key) { (category, items) in
                                Section {
                                    ForEach(items) { account in
                                        NavigationLink { AccountDetailView(account: account) } label: { AccountRowView(account: account) }
                                    }
                                } header: {
                                    HStack(spacing: 8) {
                                        Circle().fill(category.color).frame(width: 10, height: 10)
                                        Text(category.localizedName)
                                        Spacer()
                                        Text(repo.balance(for: items).toString)
                                    }
                                }
                            }
                            Color.clear
                                .frame(height: 100)
                                .listRowBackground(Color.clear)
                        }
                        .listStyle(.sidebar)
                    }
                }
                .ignoresSafeArea(edges: .bottom)
                
                Button(action: { showingAddAccount = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(18)
                        .background(
                            Circle()
                                .fill(Color.accentColor)
                                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                        )
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    NavigationLink {
                        AccountsView()
                    } label: {
                        HStack(spacing: 4) {
                            Text("Accounts")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.primary)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddAccount) {
                NavigationStack {
                    AddAccountView()
                }
            }
#else
            ZStack(alignment: .bottomTrailing) {
                VStack(alignment: .center) {
                    if !repo.balance(for: accounts).isZero {
                        Picker("", selection: $selectedChart) {
                            Text(selectedChart == 0 ? "􀜋 \(String(localized: "Distribution"))" : "􀑀 \(String(localized: "Distribution"))").tag(0)
                            Text(selectedChart == 1 ? "􀐿 \(String(localized: "Monitoring"))" : "􀐾 \(String(localized: "Monitoring"))").tag(1)
                        }
                        .pickerStyle(.segmented)
                        .padding(.bottom, 8)
                        
                        if selectedChart == 0 {
                            PieChartView()
                        } else {
                            TotalChartView(snapshots: snapshots)
                        }
                    }
                    
                    if accounts.isEmpty {
                        ContentUnavailableView("No accounts", systemImage: "creditcard")
                    } else {
                        List {
                            let groups = repo.groupByCategory(accounts).sorted {
                                $0.key.localizedCategory < $1.key.localizedCategory
                            }
                            ForEach(Array(groups), id: \.key) { (category, items) in
                                Section {
                                    ForEach(items) { account in
                                        NavigationLink { AccountDetailView(account: account) } label: { AccountRowView(account: account) }
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
                        }
                        .listStyle(.plain)
                    }
                }
                .padding()
                .ignoresSafeArea(edges: .bottom)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    NavigationLink {
                        AccountsView()
                    } label: {
                        HStack(spacing: 4) {
                            Text("Accounts")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.primary)
                        }
                    }
                }
                ToolbarItem(placement: .automatic) {
                    Button(action: { showingAddAccount = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationDestination(isPresented: $showingAddAccount) {
                AddAccountView()
            }
#endif
        }
        .onChange(of: scenePhase) { old, newPhase in
            print("ℹ️ \(scenePhase)")
            repo.update(accounts: accounts)
        }
    }
    
    
    
}

#Preview {
    AccountsDashboardView()
        .modelContainer(for: [Account.self, BalanceSnapshot.self], inMemory: true)
}

struct DashboardTip: Tip {
    
    var title: Text {
        Text("tipDashboardTitle")
    }
    
    var message: Text? {
        Text("tipDashboardDescription")
    }
    
    var image: Image? {
        Image(systemName: "chart.bar.fill")
    }
    
    var options: [Option] {
        MaxDisplayCount(2)
    }
}

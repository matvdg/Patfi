import SwiftUI
import SwiftData
import Playgrounds

struct AccountsDashboardView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Account.name, order: .forward) private var accounts: [Account]
    @State private var showingAddAccount = false
    @State private var selectedChart = 0
    
    var body: some View {
        NavigationStack {
#if os(iOS) || os(tvOS) || os(visionOS)
            ZStack(alignment: .bottomTrailing) {
                VStack(alignment: .leading) {
                    if !totalBalance.isZero {
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
                                        TotalChartView()
                                        Spacer()
                                    }
                                } label: {
                                    DashboardTotalChartView()
                                }
                            }
                        }
                        
                        .tabViewStyle(.page)
                        .indexViewStyle(.page(backgroundDisplayMode: .always))
                    }
                    
                    if accounts.isEmpty {
                        ContentUnavailableView("No accounts", systemImage: "creditcard")
                    } else {
                        List {
                            ForEach(accounts.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }) { account in
                                NavigationLink { AccountDetailView(account: account) } label: { AccountRowView(account: account) }
                            }
                        }
                        .listStyle(.plain)
                    }
                }
                .padding()
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
                VStack(alignment: .leading) {
                    if !totalBalance.isZero {
                        Picker("Select Chart", selection: $selectedChart) {
                            Text("Distribution").tag(0)
                            Text("Monitoring").tag(1)
                        }
                        .pickerStyle(.segmented)
                        .padding(.bottom, 8)
                        
                        if selectedChart == 0 {
                            PieChartView()
                        } else {
                            TotalChartView()
                        }
                    }
                    
                    if accounts.isEmpty {
                        ContentUnavailableView("No accounts", systemImage: "creditcard")
                    } else {
                        List {
                            ForEach(accounts.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }) { account in
                                NavigationLink { AccountDetailView(account: account) } label: { AccountRowView(account: account) }
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
    }
    
    private var totalBalance: Double {
        accounts.reduce(0) { total, account in
            total + (account.latestBalance?.balance ?? 0)
        }
    }
    
}

#Preview {
    AccountsDashboardView()
        .modelContainer(for: [Account.self, BalanceSnapshot.self], inMemory: true)
}

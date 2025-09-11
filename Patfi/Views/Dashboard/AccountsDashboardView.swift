import SwiftUI
import SwiftData
import Playgrounds

struct AccountsDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Account.name, order: .forward) private var accounts: [Account]
    @State private var showingAddAccount = false

    private enum Grouping: String, CaseIterable, Identifiable {
        case bank, category, name
        var id: String { rawValue }
        var title: LocalizedStringResource {
            switch self {
            case .bank: return "Bank"
            case .category: return "Category"
            case .name: return "Name"
            }
        }
    }
    @State private var grouping: Grouping = .bank

    var body: some View {
        NavigationStack {
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

                    // Segmented control for list grouping
                    Picker("Grouping", selection: $grouping) {
                        ForEach(Grouping.allCases) { g in
                            Text(g.title).tag(g)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, 8)

                    if accounts.isEmpty {
                        ContentUnavailableView("No accounts", systemImage: "creditcard")
                    } else {
                        List {
                            switch grouping {
                            case .name:
                                ForEach(accounts.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }) { account in
                                    NavigationLink { AccountDetailView(account: account) } label: { AccountRowView(account: account) }
                                }

                            case .category:
                                // Group by Category
                                let groupedByCategory = Dictionary(grouping: accounts) { $0.category }
                                ForEach(groupedByCategory.keys.sorted(by: { localizedCategory($0) < localizedCategory($1) }), id: \Category.rawValue) { cat in
                                    if let items = groupedByCategory[cat]?.sorted(by: { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }) {
                                        Section {
                                            ForEach(items) { account in
                                                NavigationLink { AccountDetailView(account: account) } label: { AccountRowView(account: account) }
                                            }
                                        } header: {
                                            HStack(spacing: 8) {
                                                Circle().fill(cat.color).frame(width: 10, height: 10)
                                                Text(cat.localizedName)
                                            }
                                        }
                                    }
                                }

                            case .bank:
                                // Group by Bank (optional). "No bank" section at the end if needed.
                                let withBank = accounts.filter { $0.bank != nil }
                                let noBank = accounts.filter { $0.bank == nil }
                                let groupedByBank = Dictionary(grouping: withBank) { $0.bank!.persistentModelID }
                                let sortedBankIDs = groupedByBank.keys.sorted { lhs, rhs in
                                    let lName = groupedByBank[lhs]?.first?.bank?.name ?? ""
                                    let rName = groupedByBank[rhs]?.first?.bank?.name ?? ""
                                    return lName.localizedCaseInsensitiveCompare(rName) == .orderedAscending
                                }
                                ForEach(sortedBankIDs, id: \.self) { bankID in
                                    if let items = groupedByBank[bankID]?.sorted(by: { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }),
                                       let bank = items.first?.bank {
                                        Section {
                                            ForEach(items) { account in
                                                NavigationLink { AccountDetailView(account: account) } label: { AccountRowView(account: account) }
                                            }
                                        } header: { bankHeader(bank) }
                                    }
                                }
                                if !noBank.isEmpty {
                                    Section {
                                        ForEach(noBank.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }) { account in
                                            NavigationLink { AccountDetailView(account: account) } label: { AccountRowView(account: account) }
                                        }
                                    } header: { bankHeader(nil) }
                                }
                            }
                        }
                        .listStyle(.plain)
                    }
                }
                .padding()

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
            .navigationTitle("Accounts")
            .sheet(isPresented: $showingAddAccount) {
                AddAccountView()
            }
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


    
    private func localizedCategory(_ c: Category) -> String {
        String(localized: c.localizedName)
    }

    @ViewBuilder
    private func bankHeader(_ bank: Bank?) -> some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill((bank?.swiftUIColor ?? Color.gray).opacity( bank == nil ? 0.3 : 1.0))
                    .frame(width: 14, height: 14)
                Text(bankInitial(bank))
                    .font(.caption2.bold())
                    .foregroundStyle(.white)
                    .opacity(bank == nil ? 0 : 1)
            }
            Text(bank?.name.isEmpty == false ? (bank?.name ?? "") : (bank == nil ? String(localized: "No bank") : "—"))
        }
    }

    private func bankInitial(_ bank: Bank?) -> String {
        guard let bank else { return "?" }
        let trimmed = bank.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.first.map { String($0).uppercased() } ?? "?"
    }

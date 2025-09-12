import SwiftUI
import SwiftData
import Playgrounds

struct AccountsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Account.name, order: .forward) private var accounts: [Account]
    
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
            VStack {
                
                // Segmented control for list grouping
                Picker("", selection: $grouping) {
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
                            ForEach(groupedByCategory.keys.sorted(by: { $0.localizedCategory < $1.localizedCategory }), id: \Category.rawValue) { cat in
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
                                    } header: { BankHeader(bank: bank) }
                                }
                            }
                            if !noBank.isEmpty {
                                Section {
                                    ForEach(noBank.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }) { account in
                                        NavigationLink { AccountDetailView(account: account) } label: { AccountRowView(account: account) }
                                    }
                                } header: { BankHeader() }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .padding()
        }
        .navigationTitle("Accounts")
    }
}

#Preview {
    AccountsView()
        .modelContainer(for: [Account.self, BalanceSnapshot.self], inMemory: true)
}

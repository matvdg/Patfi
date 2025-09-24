import SwiftUI
import SwiftData
import Playgrounds

struct AccountsView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Account.name, order: .forward) private var accounts: [Account]
    @State private var showingAddAccount = false
    
    private let repo = BalanceRepository()
    
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
                
                if accounts.isEmpty {
                    ContentUnavailableView("No accounts", systemImage: "creditcard")
                } else {
                    
                    // Segmented control for list grouping
                    Picker("", selection: $grouping) {
                        ForEach(Grouping.allCases) { g in
                            Text(g.title).tag(g)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, 8)
                    
                    List {
                        switch grouping {
                        case .name:
                            ForEach(accounts.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }) { account in
                                NavigationLink { AccountDetailView(account: account) } label: { AccountRowView(account: account) }
                            }
                        case .category:
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
                        case .bank:
                            let groups = repo.groupByBank(accounts).sorted {
                                $0.key.name < $1.key.name
                            }
                            ForEach(Array(groups), id: \.key) { (bank, items) in
                                let sortedItems = items.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
                                Section {
                                    ForEach(sortedItems) { account in
                                        NavigationLink { AccountDetailView(account: account) } label: { AccountRowView(account: account, displayBankLogo: false) }
                                    }
                                } header: {
                                    HStack {
                                        BankRow(bank: bank)
                                        Spacer()
                                        Text(repo.balance(for: sortedItems).toString)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .padding()
        }
        .navigationTitle("Accounts")
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
    }
}

#Preview {
    AccountsView()
        .modelContainer(for: [Account.self, BalanceSnapshot.self], inMemory: true)
}

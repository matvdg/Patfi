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
                            let groups = repo.groupByCategory(accounts)
                            ForEach(Array(groups.enumerated()), id: \.0) { index, element in
                                let cat = element.key
                                let items = element.value
                                Section {
                                    ForEach(items) { account in
                                        NavigationLink { AccountDetailView(account: account) } label: { AccountRowView(account: account) }
                                    }
                                } header: {
                                    HStack(spacing: 8) {
                                        Circle().fill(cat.color).frame(width: 10, height: 10)
                                        Text(cat.localizedName)
                                        Spacer()
                                        Text(repo.totalBalance(accounts: items).toString)
                                    }
                                }
                            }
                            
                        case .bank:
                            let groups = repo.groupByBank(accounts)
                            ForEach(Array(groups.enumerated()), id: \.0) { index, element in
                                let items = element.value.sorted(by: { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending })
                                if let bank = items.first?.bank {
                                    Section {
                                        ForEach(items) { account in
                                            NavigationLink { AccountDetailView(account: account) } label: { AccountRowView(account: account) }
                                        }
                                    } header: {
                                        HStack {
                                            BankRow(bank: bank)
                                            Spacer()
                                            Text(repo.totalBalance(accounts: items).toString)
                                        }
                                    }
                                }
                            }
                            if let noBank = groups[nil], !noBank.isEmpty {
                                Section {
                                    ForEach(noBank.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }) { account in
                                        NavigationLink { AccountDetailView(account: account) } label: { AccountRowView(account: account) }
                                    }
                                } header: {
                                    HStack {
                                        BankRow()
                                        Spacer()
                                        Text(repo.totalBalance(accounts: noBank).toString)
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

import SwiftUI
import SwiftData

struct AccountsView: View {
    
    @State private var sorting: Sorting = .bank
    @State private var showSortSheet = false
    @State private var showAddAccount = false
    
    @Query private var accounts: [Account]
    
    private let repo = BalanceRepository()
    
    private var accountsByCategory: [Dictionary<Category, [Account]>.Element] {
        Array(repo.groupByCategory(accounts).sorted { $0.key.localized < $1.key.localized })
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
    
    var body: some View {
        Group {
            if accounts.isEmpty {
                ContentUnavailableView {
                    Image(systemName: "creditcard")
                } description: {
                    Text("No accounts")
                } actions: {
                    Button {
                        showAddAccount = true
                    } label: {
                        Label("Create your first account", systemImage: "plus")
                            .padding()
                    }
                    .buttonStyle(.glassProminent)
                    .navigationDestination(isPresented: $showAddAccount) {
                        AddAccountView()
                    }
                }
            } else {
                let sorted = accounts.sorted {
                    switch sorting {
                    case .name: return $0.name < $1.name
                    default: return $0.latestBalance?.balance ?? 0 > $1.latestBalance?.balance ?? 0
                    }
                }
                List {
                    switch sorting {
                    case .category:
                        ForEach(accountsByCategory, id: \.key) { (category, items) in
                            Section {
                                ForEach(items) { account in
                                    NavigationLink {
                                        AccountDetailView(account: account)
                                            .toolbar(.hidden, for: .bottomBar)
                                    } label: {
                                        AccountRow(account: account)
                                    }
                                }
                            } header: {
                                VStack(alignment: .center, spacing: 8) {
                                    Spacer()
                                    HStack(spacing: 8) {
                                        Circle().fill(category.color).frame(width: 10, height: 10)
                                        Text(category.localized)
                                        Spacer()
                                        Text(repo.balance(for: items).toString)
                                    }
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.1)
                                }
                            }
                        }
                    case .bank:
                        ForEach(accountsByBank, id: \.key) { (bank, items) in
                            Section {
                                ForEach(items) { account in
                                    NavigationLink {
                                        AccountDetailView(account: account)
                                            .toolbar(.hidden, for: .bottomBar)
                                    } label: {
                                        AccountRow(account: account, displayBankLogo: false)
                                    }
                                }
                            } header: {
                                HStack {
                                    BankRow(bank: bank)
                                    Spacer()
                                    Text(repo.balance(for: items).toString)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.1)
                                }
                                .padding(.bottom, 1)
                            }
                        }
                    default:
                        ForEach(sorted) { account in
                            NavigationLink {
                                AccountDetailView(account: account)
                                    .toolbar(.hidden, for: .bottomBar)
                            } label: {
                                AccountRow(account: account)
                            }
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        Button {
                            showSortSheet = true
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        NavigationLink {
                            AddAccountView()
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showSortSheet) {
                    SortView(sorting: $sorting)
                }
            }
        }
        .navigationTitle("Accounts")
    }
}

#Preview {
    AccountsView()
        .modelContainer(ModelContainer.getSharedContainer())
}

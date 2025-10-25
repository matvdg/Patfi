import SwiftUI
import SwiftData

struct AccountsView: View {
    
    @State private var sorting: Sorting = .bank
    @State private var showSortSheet = false
    @State private var showAddAccount = false
    
    @Query private var accounts: [Account]
    
    private let balanceRepository = BalanceRepository()
    private let accountRepository = AccountRepository()
    
    private var accountsByCategory: [AccountsPerCategory.Element] {
        Array(accountRepository.groupByCategory(accounts))
            .sorted {
                balanceRepository.balance(for: $0.value) > balanceRepository.balance(for: $1.value)
            }
    }
    
    private var accountsByBank: [AccountsPerBank.Element] {
        Array(accountRepository.groupByBank(accounts))
            .sorted {
                balanceRepository.balance(for: $0.value) > balanceRepository.balance(for: $1.value)
            }
    }
    
    var body: some View {
        Group {
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
                                        AmountText(amount: balanceRepository.balance(for: items))
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
                                        AccountRow(account: account)
                                    }
                                }
                            } header: {
                                VStack(alignment: .center, spacing: 8) {
                                    Spacer()
                                    HStack(spacing: 8) {
                                        Circle().fill(bank.swiftUIColor).frame(width: 10, height: 10)
                                        Text(bank.name)
                                        Spacer()
                                        AmountText(amount: balanceRepository.balance(for: items))
                                    }
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.1)
                                }
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
        .navigationTitle("accounts")
    }
}

#Preview {
    NavigationStack { AccountsView() }
        .modelContainer(ModelContainer.shared)
}

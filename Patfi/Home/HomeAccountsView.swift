import SwiftUI
import SwiftData
import Playgrounds

struct HomeAccountsView: View {
    
    @Environment(\.modelContext) private var context
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    @Query(sort: \Account.name, order: .forward) private var accounts: [Account]
    @AppStorage(Keys.isGraphHidden) private var isGraphHidden = false
    @AppStorage(Keys.sortByBank) private var sortByBank = false

    @State private var collapsedSectionsByBank: Set<String> = []
    @State private var collapsedSectionsByCategory: Set<String> = []
    @State private var editBankColor: Bank? = nil
    
    private var allBankSectionKeys: [String] { accountsByBank.map { $0.key.normalizedName } }
    private var allCategorySectionKeys: [String] { accountsByCategory.map { $0.key.rawValue } }
    private var allBankSectionsCollapsed: Bool { collapsedSectionsByBank.count == allBankSectionKeys.count }
    private var allCategorySectionsCollapsed: Bool { collapsedSectionsByCategory.count == allCategorySectionKeys.count }
    private var allCollapsedBankSectionsBinding: Binding<Bool> {
        Binding(
            get: {
                allBankSectionsCollapsed },
            set: { newValue in
                if newValue {
                    collapsedSectionsByBank = Set(allBankSectionKeys)
                } else {
                    collapsedSectionsByBank.removeAll()
                }
            }
        )
    }
    private var allCollapsedCategorySectionsBinding: Binding<Bool> {
        Binding(
            get: {
                allCategorySectionsCollapsed },
            set: { newValue in
                if newValue {
                    collapsedSectionsByCategory = Set(allCategorySectionKeys)
                } else {
                    collapsedSectionsByCategory.removeAll()
                }
            }
        )
    }
    
    private let balanceRepository = BalanceRepository()
    private let accountRepository = AccountRepository()
    
    private var accountsByCategory: [AccountsPerCategory.Element] {
        Array(accountRepository.groupByCategory(accounts).sorted { $0.key.localized < $1.key.localized })
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
    
    private var isLandscape: Bool {
#if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .phone && verticalSizeClass == .compact
#else
        return false
#endif
    }
    
    var body: some View {
        
        VStack(alignment: .center) {
            
            Group {
                PieChartView(accounts: accounts, transactions: [], grouping: .accounts, sortByBank: sortByBank)
            }
            .frame(height: isGraphHidden ? 0 : nil)
            .opacity(isGraphHidden ? 0 : 1)
            ZStack {
                ArrowButton(isUp: $isGraphHidden)
                HStack {
                    BankButton(sortByBank: $sortByBank).padding(.leading, 12)
                    Spacer()
                    CollapseButton(isCollapsed: sortByBank ? allCollapsedBankSectionsBinding : allCollapsedCategorySectionsBinding).padding(.trailing, 12)
                }
            }
            if sortByBank {
                List {
                    ForEach(accountsByBank, id: \.key) { (bank, items) in
                        let isCollapsed = collapsedSectionsByBank.contains(bank.normalizedName)
                        Section {
                            if !isCollapsed {
                                ForEach(items) { account in
                                    NavigationLink { AccountDetailView(account: account) } label: { AccountRow(account: account) }
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button(role: .confirm) {
                                                editBankColor = bank
                                            } label: {
                                                Label("EditBank", systemImage: "paintpalette")
                                            }
                                        }
                                        .contextMenu {
                                            Button(role: .confirm) {
                                                editBankColor = bank
                                            } label: {
                                                Label("EditBank", systemImage: "paintpalette")
                                            }
                                        }
                                }
                            }
                        } header: {
                            ArrowRightButton(isRight: Binding(
                                get: { isCollapsed },
                                set: { isCollapsed in
                                    if isCollapsed {
                                        collapsedSectionsByBank.insert(bank.normalizedName)
                                    } else {
                                        collapsedSectionsByBank.remove(bank.normalizedName)
                                    }
                                }
                            )) {
                                HStack {
                                    Circle()
                                        .fill(Color(bank.swiftUIColor))
                                        .frame(width: 10, height: 10)
                                    Text(bank.name)
                                    Spacer()
                                    AmountText(amount: balanceRepository.balance(for: items))
                                }
                                .onLongPressGesture {
                                    editBankColor = bank
                                }
                            }
                        }
                    }
                }
            } else {
                List {
                    ForEach(accountsByCategory, id: \.key) { (category, items) in
                        let isCollapsed = collapsedSectionsByCategory.contains(category.rawValue)
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
                                        collapsedSectionsByCategory.insert(category.rawValue)
                                    } else {
                                        collapsedSectionsByCategory.remove(category.rawValue)
                                    }
                                }
                            )) {
                                HStack(spacing: 8) {
                                    Circle().fill(category.color).frame(width: 10, height: 10)
                                    Text(category.localized)
                                    Spacer()
                                    AmountText(amount: balanceRepository.balance(for: items))
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
                }
            }
        }
        .onChange(of: collapsedSectionsByBank) {
            Keys.saveSet(collapsedSectionsByBank, forKey: Keys.collapsedSectionsByBank)
        }
        .onChange(of: collapsedSectionsByCategory) {
            Keys.saveSet(collapsedSectionsByCategory, forKey: Keys.collapsedSectionsByCategory)
        }
        .onAppear {
            collapsedSectionsByBank = Keys.loadSet(forKey: Keys.collapsedSectionsByBank)
            collapsedSectionsByCategory = Keys.loadSet(forKey: Keys.collapsedSectionsByCategory)
        }
        .navigationDestination(item: $editBankColor, destination: { bank in
            EditBankView(bank: bank)
        })
        .navigationTitle(isLandscape ? "" : "Accounts")
    }
}

#Preview {
    NavigationStack {
        HomeAccountsView()
            .modelContainer(ModelContainer.shared)
    }
}

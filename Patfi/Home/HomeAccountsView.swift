import SwiftUI
import SwiftData
import Playgrounds

struct HomeAccountsView: View {
    
    @Environment(\.modelContext) private var context
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    @Query(sort: \Account.name, order: .forward) private var accounts: [Account]
    @State private var isGraphHidden = false
    @State private var collapsedSections: Set<String> = []
    @State private var sortByBank: Bool = false
    @State private var editBankColor: Bank? = nil
    
    private var allKeys: [String] {
        if sortByBank {
            accountsByBank.map { $0.key.normalizedName }
        } else {
            accountsByCategory.map { $0.key.rawValue }
        }
    }
    private var allCollapsed: Bool {
        collapsedSections.count == allKeys.count
    }
    private var allCollapsedBinding: Binding<Bool> {
        Binding(
            get: {
                allCollapsed },
            set: { newValue in
                if newValue {
                    collapsedSections = Set(allKeys)
                } else {
                    collapsedSections.removeAll()
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
                    CollapseButton(isCollapsed: allCollapsedBinding).padding(.trailing, 12)
                }
            }
            if sortByBank {
                List {
                    ForEach(accountsByBank, id: \.key) { (bank, items) in
                        let isCollapsed = collapsedSections.contains(bank.normalizedName)
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
                            } else {
                                EmptyView().frame(height: 100)
                            }
                        } header: {
                            ArrowRightButton(isRight: Binding(
                                get: { isCollapsed },
                                set: { isCollapsed in
                                    if isCollapsed {
                                        collapsedSections.insert(bank.normalizedName)
                                    } else {
                                        collapsedSections.remove(bank.normalizedName)
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
                        let isCollapsed = collapsedSections.contains(category.rawValue)
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
                                        collapsedSections.insert(category.rawValue)
                                    } else {
                                        collapsedSections.remove(category.rawValue)
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
        .onChange(of: isLandscape) {
            isGraphHidden = false
        }
        .onChange(of: sortByBank) {
            collapsedSections.removeAll()
            allCollapsedBinding.wrappedValue = true
        }
        .onAppear {
            allCollapsedBinding.wrappedValue = true
        }
        .navigationDestination(item: $editBankColor, destination: { bank in
            EditBankView(bank: bank)
        })
        .navigationTitle(isLandscape ? "" : "Accounts")
    }
}

#Preview {
    HomeAccountsView()
        .modelContainer(ModelContainer.shared)
}

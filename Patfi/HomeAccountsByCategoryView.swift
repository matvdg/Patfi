import SwiftUI
import SwiftData
import Playgrounds

struct HomeAccountsByCategoryView: View {
    
    @Environment(\.modelContext) private var context
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    @Query(sort: \Account.name, order: .forward) private var accounts: [Account]
    @State private var isGraphHidden = false
    @State private var collapsedSections: Set<String> = []
    
    private var allKeys: [String] {
        accountsByCategory.map { $0.key.localized }
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
                PieChartView(accounts: accounts, transactions: [], grouping: .categories)
            }
            .frame(height: isGraphHidden ? 0 : nil)
            .opacity(isGraphHidden ? 0 : 1)
            if !isLandscape {
                ZStack {
                    ArrowButton(isUp: $isGraphHidden)
                    HStack {
                        Spacer()
                        CollapseButton(isCollapsed: allCollapsedBinding).padding(.trailing, 12)
                    }
                }
                List {
                    ForEach(accountsByCategory, id: \.key) { (category, items) in
                        let isCollapsed = collapsedSections.contains(category.localized)
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
                                        collapsedSections.insert(category.localized)
                                    } else {
                                        collapsedSections.remove(category.localized)
                                    }
                                }
                            )) {
                                HStack(spacing: 8) {
                                    Circle().fill(category.color).frame(width: 10, height: 10)
                                    Text(category.localized)
                                    Spacer()
                                    Text(balanceRepository.balance(for: items).toString)
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
                .scrollIndicators(.hidden)
#if os(macOS)
                .listStyle(.plain)
                .padding()
#else
                .listStyle(.insetGrouped)
#endif
            }
        }
        .onChange(of: isLandscape) {
            isGraphHidden = false
        }
        .onAppear {
            allCollapsedBinding.wrappedValue = true
        }
        .navigationTitle("accounts")
    }
}

#Preview {
    HomeAccountsByCategoryView()
        .modelContainer(ModelContainer.shared)
}

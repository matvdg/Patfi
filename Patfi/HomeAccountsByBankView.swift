import SwiftUI
import SwiftData
import Playgrounds

struct HomeAccountsByBankView: View {
    
    @Environment(\.modelContext) private var context
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    @Query(sort: \Account.name, order: .forward) private var accounts: [Account]
    @State private var isGraphHidden = false
    @State private var editBankColor: Bank? = nil
    @State private var collapsedSections: Set<String> = []
    
    private var allKeys: [String] {
        accountsByBank.map { $0.key.normalizedName }
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
                PieChartView(accounts: accounts, transactions: [], grouping: .banks)
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
                                                Label("editBank", systemImage: "paintpalette")
                                            }
                                        }
                                        .contextMenu {
                                            Button(role: .confirm) {
                                                editBankColor = bank
                                            } label: {
                                                Label("editBank", systemImage: "paintpalette")
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
                                    Text(balanceRepository.balance(for: items).toString)
                                }
                                .onLongPressGesture {
                                    editBankColor = bank
                                }
                            }
                            
                            .frame(height: isCollapsed ? 22 : 30)
                            .padding(.top, isCollapsed ? 4 : 0)
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
        .navigationDestination(item: $editBankColor, destination: { bank in
            EditBankView(bank: bank)
        })
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
    HomeAccountsByBankView()
        .modelContainer(ModelContainer.shared)
}

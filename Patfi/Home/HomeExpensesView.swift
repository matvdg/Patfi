import SwiftUI
import SwiftData
import Playgrounds

struct HomeExpensesView: View {
    
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    @AppStorage(Keys.selectedDate) private var selectedDate: Date = Date()
    @AppStorage(Keys.selectedPeriod) private var selectedPeriod: Period = .month
    
    private var isLandscape: Bool {
#if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .phone && verticalSizeClass == .compact
#else
        return false
#endif
    }
    
    var body: some View {
        
        VStack(alignment: .center) {
            if !isLandscape {
                PeriodPicker(selectedDate: $selectedDate, selectedPeriod: $selectedPeriod)
            }
            ExpensesView(for: selectedPeriod, containing: selectedDate)
        }
    }
}

struct ExpensesView: View {
    
    init(for selectedPeriod: Period, containing selectedDate: Date) {
        self.selectedDate = selectedDate
        self.selectedPeriod = selectedPeriod
        _transactions = Query(filter: Transaction.predicate(for: selectedPeriod, containing: selectedDate), sort: \.date, order: .reverse)
    }
    
    private var selectedDate: Date
    private var selectedPeriod: Period
    
    @Query private var transactions: [Transaction]
    @Environment(\.modelContext) private var context
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @AppStorage(Keys.isGraphHidden) private var isGraphHidden = false
    @AppStorage(Keys.sortByPaymentMethod) private var sortByPaymentMethod = false
    
    @State private var collapsedSectionsByPaymentMethod: Set<String> = []
    @State private var collapsedSectionsByCategory: Set<String> = []
    @State private var editBankColor: Bank? = nil
    
    private var allPaymentMethodSectionKeys: [String] { transactionRepository.groupByPaymentMethod(transactions).map { $0.key.id } }
    private var allCategorySectionKeys: [String] { transactionRepository.groupByCategory(transactions).map { $0.key.id } }
    private var allPaymentMethodSectionsCollapsed: Bool { collapsedSectionsByPaymentMethod.count == allPaymentMethodSectionKeys.count }
    private var allCategorySectionsCollapsed: Bool { collapsedSectionsByCategory.count == allCategorySectionKeys.count }
    
    private var allCollapsedPaymentMethodSectionsBinding: Binding<Bool> {
        Binding(
            get: {
                allPaymentMethodSectionsCollapsed },
            set: { newValue in
                if newValue {
                    collapsedSectionsByPaymentMethod = Set(allPaymentMethodSectionKeys)
                } else {
                    collapsedSectionsByPaymentMethod.removeAll()
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
        
    private let transactionRepository = TransactionRepository()
    
    private var isLandscape: Bool {
#if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .phone && verticalSizeClass == .compact
#else
        return false
#endif
    }
    
    private var expenses: [Transaction] {
        transactions.filter { $0.expenseCategory != nil }
    }
    
    private var expensesByCategory: [TransactionsPerCategory.Element] {
        Array(transactionRepository.groupByCategory(expenses))
            .sorted {
                transactionRepository.total(for: $0.value) > transactionRepository.total(for: $1.value)
            }
    }
    
    private var expensesByPaymentMethod: [TransactionsPerPaymentMethod.Element] {
        Array(transactionRepository.groupByPaymentMethod(expenses))
            .sorted {
                transactionRepository.total(for: $0.value) > transactionRepository.total(for: $1.value)
            }
    }
    
    var body: some View {
        Group {
            if transactions.isEmpty {
                VStack {
                    ContentUnavailableView(
                        "NoData",
                        systemImage: "receipt",
                        description: Text("DescriptionEmptyTransactions")
                    )
                    Spacer()
                }
            } else {
                
                VStack {
                    PieChartView(accounts: [], transactions: expenses, grouping: .expenses, sortByPaymentMethod: sortByPaymentMethod)
                        .frame(height: isGraphHidden ? 0 : nil)
                        .opacity(isGraphHidden ? 0 : 1)
                    ZStack {
                        ArrowButton(isUp: $isGraphHidden)
                        HStack {
                            PaymentMethodButton(sortByPaymentMethod: $sortByPaymentMethod).padding(.leading, 12)
                            Spacer()
                            CollapseButton(isCollapsed: sortByPaymentMethod ? allCollapsedPaymentMethodSectionsBinding : allCollapsedCategorySectionsBinding).padding(.trailing, 12)
                        }
                    }
                    if sortByPaymentMethod {
                        List {
                            ForEach(expensesByPaymentMethod, id: \.key) { (paymentMethod, expenses) in
                                let isCollapsed = collapsedSectionsByPaymentMethod.contains(paymentMethod.id)
                                Section {
                                    if !isCollapsed {
                                        ForEach(expenses) { expense in
                                            NavigationLink {
                                                EditTransactionView(transaction: expense)
                                            } label: {
                                                TransactionRow(transaction: expense, showPaymentMethodLogo: true)
                                            }
                                            .swipeActions(edge: .trailing) {
                                                Button(role: .destructive) {
                                                    transactionRepository.delete(expense, context: context)
                                                } label: { Label("Delete", systemImage: "trash") }
                                            }
#if !os(watchOS)
                                            .contextMenu {
                                                Button(role: .destructive) {
                                                    transactionRepository.delete(expense, context: context)
                                                } label: {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                            }
#endif
                                        }
                                    } else {
                                        EmptyView().frame(height: 100)
                                    }
                                } header: {
                                    ArrowRightButton(isRight: Binding(
                                        get: { isCollapsed },
                                        set: { isCollapsed in
                                            if isCollapsed {
                                                collapsedSectionsByPaymentMethod.insert(paymentMethod.id)
                                            } else {
                                                collapsedSectionsByPaymentMethod.remove(paymentMethod.id)
                                            }
                                        }
                                    )) {
                                        HStack(spacing: 8) {
                                            Circle().fill(paymentMethod.color).frame(width: 10, height: 10)
                                            Text(paymentMethod.localized).minimumScaleFactor(0.5)
                                            Spacer()
                                            AmountText(amount: -transactionRepository.total(for: expenses))
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
                    } else {
                        List {
                            ForEach(expensesByCategory, id: \.key) { (cat, expenses) in
                                let isCollapsed = collapsedSectionsByCategory.contains(cat.id)
                                Section {
                                    if !isCollapsed {
                                        ForEach(expenses) { expense in
                                            NavigationLink {
                                                EditTransactionView(transaction: expense)
                                            } label: {
                                                TransactionRow(transaction: expense)
                                            }
                                            .swipeActions(edge: .trailing) {
                                                Button(role: .destructive) {
                                                    transactionRepository.delete(expense, context: context)
                                                } label: { Label("Delete", systemImage: "trash") }
                                            }
#if !os(watchOS)
                                            .contextMenu {
                                                Button(role: .destructive) {
                                                    transactionRepository.delete(expense, context: context)
                                                } label: {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                            }
#endif
                                        }
                                    } else {
                                        EmptyView().frame(height: 100)
                                    }
                                } header: {
                                    ArrowRightButton(isRight: Binding(
                                        get: { isCollapsed },
                                        set: { isCollapsed in
                                            if isCollapsed {
                                                collapsedSectionsByCategory.insert(cat.id)
                                            } else {
                                                collapsedSectionsByCategory.remove(cat.id)
                                            }
                                        }
                                    )) {
                                        HStack(spacing: 8) {
                                            Circle().fill(cat.color).frame(width: 10, height: 10)
                                            Text(cat.localized).minimumScaleFactor(0.5)
                                            Spacer()
                                            AmountText(amount: -transactionRepository.total(for: expenses))
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
                    }
                }
                .onChange(of: collapsedSectionsByPaymentMethod) {
                    Keys.saveSet(collapsedSectionsByPaymentMethod, forKey: Keys.collapsedSectionsByPaymentMethod)
                }
                .onChange(of: collapsedSectionsByCategory) {
                    Keys.saveSet(collapsedSectionsByCategory, forKey: Keys.collapsedSectionsByExpenseCategory)
                }
                .onAppear {
                    collapsedSectionsByPaymentMethod = Keys.loadSet(forKey: Keys.collapsedSectionsByPaymentMethod)
                    collapsedSectionsByCategory = Keys.loadSet(forKey: Keys.collapsedSectionsByExpenseCategory)
                }
            }
        }
        .navigationTitle(isLandscape ? "" : "Expenses")
    }
}

#Preview {
    HomeExpensesView()
        .modelContainer(ModelContainer.shared)
}

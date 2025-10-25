import SwiftUI
import SwiftData
import Playgrounds

struct HomeExpensesView: View {
    
    @State private var selectedDate: Date = .now
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State var period: Period = .months
    
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
                PeriodPicker(selectedDate: $selectedDate, period: $period)
            }
            ExpensesView(for: period, containing: selectedDate)
        }
    }
}

struct ExpensesView: View {
    
    init(for period: Period, containing selectedDate: Date) {
        self.selectedDate = selectedDate
        self.period = period
        _transactions = Query(filter: Transaction.predicate(for: period, containing: selectedDate), sort: \.date, order: .reverse)
    }
    
    var selectedDate: Date
    var period: Period
    
    @Query private var transactions: [Transaction]
    @Environment(\.modelContext) private var context
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var collapsedSections: Set<String> = []
    @State private var isGraphHidden = false
    @State private var sortByPaymentMethod = false
    
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
    
    private var allKeys: [String] {
        if sortByPaymentMethod {
            transactionRepository.groupByPaymentMethod(transactions).map { $0.key.id }
        } else {
            transactionRepository.groupByCategory(transactions).map { $0.key.id }
        }
    }
    
    private var allCollapsed: Bool {
        collapsedSections.count == allKeys.count
    }
    
    private var allCollapsedBinding: Binding<Bool> {
        Binding(
            get: {
                allCollapsed
            },
            set: { newValue in
                if newValue {
                    collapsedSections = Set(allKeys)
                } else {
                    collapsedSections.removeAll()
                }
            }
        )
    }
    
    var body: some View {
        Group {
            if transactions.isEmpty {
                ContentUnavailableView(
                    "noData",
                    systemImage: "receipt",
                    description: Text("transactionsEmptyDescription")
                )
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
                            CollapseButton(isCollapsed: allCollapsedBinding).padding(.trailing, 12)
                        }
                    }
                    if sortByPaymentMethod {
                        List {
                            ForEach(expensesByPaymentMethod, id: \.key) { (paymentMethod, expenses) in
                                let isCollapsed = collapsedSections.contains(paymentMethod.id)
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
                                                } label: { Label("delete", systemImage: "trash") }
                                            }
#if !os(watchOS)
                                            .contextMenu {
                                                Button(role: .destructive) {
                                                    transactionRepository.delete(expense, context: context)
                                                } label: {
                                                    Label("delete", systemImage: "trash")
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
                                                collapsedSections.insert(paymentMethod.id)
                                            } else {
                                                collapsedSections.remove(paymentMethod.id)
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
                                let isCollapsed = collapsedSections.contains(cat.id)
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
                                                } label: { Label("delete", systemImage: "trash") }
                                            }
#if !os(watchOS)
                                            .contextMenu {
                                                Button(role: .destructive) {
                                                    transactionRepository.delete(expense, context: context)
                                                } label: {
                                                    Label("delete", systemImage: "trash")
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
                                                collapsedSections.insert(cat.id)
                                            } else {
                                                collapsedSections.remove(cat.id)
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
                .onChange(of: isLandscape) {
                    isGraphHidden = false
                }
                .onChange(of: sortByPaymentMethod) {
                    collapsedSections.removeAll()
                    allCollapsedBinding.wrappedValue = true
                }
                .onChange(of: selectedDate, initial: true) { oldValue, newValue in
                    collapsedSections.removeAll()
                    allCollapsedBinding.wrappedValue = true
                }
                .onChange(of: period) { oldValue, newValue in
                    collapsedSections.removeAll()
                    allCollapsedBinding.wrappedValue = true
                }
            }
        }
        .navigationTitle(isLandscape ? "" : "expenses")
    }
}

#Preview {
    HomeExpensesView()
        .modelContainer(ModelContainer.shared)
}

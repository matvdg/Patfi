import SwiftUI
import SwiftData

struct AccountDetailView: View {
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var account: Account
    
    @State private var showAddSnapshot = false
    @State private var showDeleteAccountConfirm = false
    @State private var selectedPeriod: Period = .month
    @State private var selectedDate: Date = Date()
    @State private var showActions = false
    
    private let balanceRepository = BalanceRepository()
    private let accountRepository = AccountRepository()
    
    var body: some View {
        Form {
            
            // MARK: - Balances
            Section("Balance") {
                AmountText(amount: account.latestBalance)
                NavigationLink("ViewBalanceHistory") {
                    VStack {
                        TwelvePeriodPicker(selectedDate: $selectedDate, selectedPeriod: $selectedPeriod)
                        MonitoringView(for: selectedPeriod, containing: selectedDate, account: account)
                    }
                    .onAppear {
                        selectedDate = selectedDate.normalizedDate(selectedPeriod: selectedPeriod)
                    }
                }
            }
            
            // MARK: - Transactions
            Section("Transactions") {
                NavigationLink("ViewTransactions") {
                    HomeTransactionsView(account: account)
                }
            }
            
            // MARK: - Account info & editing
            Section("Account") {
                TextField("Name", text: $account.name)
                    .disableAutocorrection(true)
                Picker("Category", selection: $account.category) {
                    ForEach(Category.allCases) { c in
                        HStack {
                            Circle().fill(c.color).frame(width: 10, height: 10)
                            Text(c.localized)
                        }
                        .tag(c)
                    }
                }
#if !os(macOS)
                .pickerStyle(.navigationLink)
#endif
                if account.isDefault {
                    Button(role: .confirm) {
                        accountRepository.unsetAsDefault(account: account, context: context)
                    } label: {
                        Label("UnsetAsDefault", systemImage: "star.slash")
                    }
                } else {
                    Button(role: .confirm) {
                        accountRepository.setAsDefault(account: account, context: context)
                    } label: {
                        Label("SetAsDefault", systemImage: "star")
                    }
                }
                
                Button(role: .destructive) {
                    showDeleteAccountConfirm = true
                } label: {
                    Label("DeleteAccount", systemImage: "trash")
                        .foregroundStyle(.red)
                }
                .confirmationDialog("DeleteAccount", isPresented: $showDeleteAccountConfirm, titleVisibility: .visible) {
                    Button("Delete", role: .destructive) {
                        accountRepository.delete(account: account, context: context)
                        dismiss()
                    }
                    Button(role: .cancel, action: { dismiss() })
                } message: {
                    Text("DescriptionDeleteAccount")
                }
            }
            
            // MARK: - Bank
            Section("Bank") {
                NavigationLink {
                    EditBanksView(selectedBank: $account.bank)
                } label: {
                    if let bank = account.bank {
                        BankRow(bank: bank).id(bank.id)
                    } else {
                        Text("SelectBank")
                            .foregroundColor(.primary)
                    }
                }
            }
            
        }
        .formStyle(.grouped)
        .navigationDestination(isPresented: $showAddSnapshot, destination: {
            AddBalanceView(account: account)
        })
        .navigationTitle(account.name.isEmpty ? String(localized: "Account") : account.name)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                #if os(watchOS)
                Button {
                    showActions = true
                } label: {
                    Image(systemName: "plus")
                }
                #else
                Menu {
                    ForEach(QuickAction.allCases, id: \.self) { action in
                        if action.requiresAccount {
                            NavigationLink {
                                action.destinationView(account: account)
                            } label: {
                                Label(action.localizedTitle, systemImage: action.iconName)
                            }
                        }
                    }
                } label: {
                    Image(systemName: "plus")
                }
                #endif
            }
        }
        .confirmationDialog("Add", isPresented: $showActions) {
            ForEach(QuickAction.allCases, id: \.self) { action in
                if action.requiresAccount {
                    NavigationLink(action.localizedTitle) {
                        action.destinationView(account: account)
                    }
                }
            }
        }
    }
}

#Preview {
    let account = Account(name: "BoursoBank", category: .savings, currentBalance: 100000)
    return NavigationStack { AccountDetailView(account: account) }.modelContainer(ModelContainer.shared)
}


import SwiftUI
import SwiftData

struct AccountDetailView: View {
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var account: Account
    
    @State private var showAddSnapshot = false
    @State private var showDeleteAccountConfirm = false
    @State private var period: Period = .months
    @State private var showActions = false
    
    private let balanceRepository = BalanceRepository()
    private let accountRepository = AccountRepository()
    
    var body: some View {
        Form {
            // MARK: - Account info & editing
            Section("account") {
                TextField("name", text: $account.name)
                    .disableAutocorrection(true)
                Picker("category", selection: $account.category) {
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
                        Label("unsetAsDefault", systemImage: "star.slash")
                    }
                } else {
                    Button(role: .confirm) {
                        accountRepository.setAsDefault(account: account, context: context)
                    } label: {
                        Label("setAsDefault", systemImage: "star")
                    }
                }
                
                Button(role: .destructive) {
                    showDeleteAccountConfirm = true
                } label: {
                    Label("deleteAccount", systemImage: "trash")
                        .foregroundStyle(.red)
                }
                .confirmationDialog("deleteAccount", isPresented: $showDeleteAccountConfirm, titleVisibility: .visible) {
                    Button("delete", role: .destructive) {
                        accountRepository.delete(account: account, context: context)
                        dismiss()
                    }
                    Button(role: .cancel, action: { dismiss() })
                } message: {
                    Text("deleteAccountDescription")
                }
            }
            
            // MARK: - Bank
            Section("bank") {
                NavigationLink {
                    EditBanksView(selectedBank: $account.bank)
                } label: {
                    if let bank = account.bank {
                        BankRow(bank: bank).id(bank.id)
                    } else {
                        Text("selectBank")
                            .foregroundColor(.primary)
                    }
                }
            }
            
            // MARK: - Balances timeline
            List {
                if let snaps = account.balances, !snaps.isEmpty {
                    NavigationLink {
                        VStack {
                            Picker("", selection: $period) {
                                ForEach(Period.allCases) { period in
                                    Text(period.localized).tag(period)
                                }
                            }
#if !os(watchOS)
                            .pickerStyle(.segmented)
#endif
                            .padding()
                            BalanceChartView(snapshots: snaps, period: period)
                            Spacer()
                        }
                    } label: {
                        VStack {
                            Picker("", selection: $period) {
                                ForEach(Period.allCases) { period in
                                    Text(period.localized).tag(period)
                                }
                            }
#if !os(watchOS)
                            .pickerStyle(.segmented)
#endif
                            BalanceChartView(snapshots: snaps, period: period)
                                .frame(height: 150)
                        }
                        
                    }
                    Button(action: { showAddSnapshot = true }) {
                        HStack(alignment: .center, spacing: 8) {
                            Image(systemName: "plus")
                            Text("addBalance")
                        }
                    }
                    .buttonStyle(.plain)
                    ForEach(snaps.sorted(by: { $0.date > $1.date })) { snap in
                        HStack {
                            Text(snap.date.toString)
                            Spacer()
                            ColorAmount(amount: snap.balance)
                                .monospacedDigit()
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                balanceRepository.delete(snap, context: context)
                            } label: { Label("delete", systemImage: "trash") }
                        }
#if !os(watchOS)
                        .contextMenu {
                            Button(role: .destructive) {
                                balanceRepository.delete(snap, context: context)
                            } label: {
                                Label("delete", systemImage: "trash")
                            }
                        }
#endif
                    }
                    Text("tipBalance").foregroundStyle(.tertiary).italic()
                } else {
                    ContentUnavailableView("noSnapshots", systemImage: "clock.arrow.circlepath", description: Text("addBalance"))
                }
            }
            .padding(.all)
        }
        .formStyle(.grouped)
        .navigationDestination(isPresented: $showAddSnapshot, destination: {
            AddBalanceView(account: account)
        })
        .navigationTitle(account.name.isEmpty ? String(localized: "account") : account.name)
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
        .confirmationDialog("add", isPresented: $showActions) {
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
    let account = Account(name: "BoursoBank", category: .savings)
    let b1 = BalanceSnapshot(date: Date(), balance: 100000, account: account)
    let b2 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*31*4), balance: 127650.55, account: account)
    let b3 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*31*15), balance: 1265.55, account: account)
    let b4 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*31*10), balance: 3000, account: account)
    let b5 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*31*9), balance: 10000, account: account)
    let b6 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*31*8), balance: 30000, account: account)
    let b7 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*31*7), balance: 100000, account: account)
    let b8 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*31*6), balance: 90000, account: account)
    let b9 = BalanceSnapshot(date: Date().addingTimeInterval(-60*60*24*31*5), balance: 100000, account: account)
    let balances = [b1, b2, b3, b4, b5, b6, b7, b8, b9]
    account.balances = balances
    return NavigationStack { AccountDetailView(account: account) }
}


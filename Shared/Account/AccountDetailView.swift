import SwiftUI
import SwiftData

struct AccountDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var account: Account
    
    @State private var showAddSnapshot = false
    @State private var showDeleteAccountConfirm = false
    @State private var period: Period = .months
    
    private let balanceRepository = BalanceRepository()
    private let accountRepository = AccountRepository()
    
    var body: some View {
        Form {
            // MARK: - Account info & editing
            Section("Account") {
                TextField("Name", text: $account.name)
                    .disableAutocorrection(true)
                    .frame(maxWidth: 300)
                HStack {
                    Circle().fill(account.category.color).frame(width: 10, height: 10)
                    Picker("Category", selection: $account.category) {
                        ForEach(Category.allCases) { c in
                            Text(c.localized)
                                .tag(c)
                        }
                    }
                }
                
                Button(role: .destructive) {
                    showDeleteAccountConfirm = true
                } label: {
                    Label("Delete account", systemImage: "trash")
                        .foregroundStyle(.red)
                }
                .confirmationDialog("Delete this account?", isPresented: $showDeleteAccountConfirm, titleVisibility: .visible) {
                    Button("Delete", role: .destructive) {
                        accountRepository.delete(account: account, context: context)
                        dismiss()
                    }
                    Button(role: .cancel, action: { dismiss() })
                } message: {
                    Text("This will also delete all its balances")
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
                        Text("Select/create/modify a bank")
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
                            TotalChartView(snapshots: snaps, period: $period)
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
                            TotalChartView(snapshots: snaps, period: $period)
                                .frame(height: 150)
                        }
                        
                    }
                    Button(action: { showAddSnapshot = true }) {
                        HStack(alignment: .center, spacing: 8) {
                            Image(systemName: "plus")
                            Text("Add balance")
                        }
                    }
                    .buttonStyle(.plain)
                    .sheet(isPresented: $showAddSnapshot) {
                        AddBalanceView(account: account)
                    }
                    ForEach(snaps.sorted(by: { $0.date > $1.date })) { snap in
                        HStack {
                            Text(snap.date.toString)
                            Spacer()
                            Text(snap.balance.toString)
                                .monospacedDigit()
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                balanceRepository.delete(snap, context: context)
                            } label: { Label("Delete", systemImage: "trash") }
                        }
#if !os(watchOS)
                        .contextMenu {
                            Button(role: .destructive) {
                                balanceRepository.delete(snap, context: context)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
#endif
                    }
                    Text("tipBalance").foregroundStyle(.tertiary).italic()
                } else {
                    ContentUnavailableView("No snapshots", systemImage: "clock.arrow.circlepath", description: Text("AddBalance"))
                }
            }
            .padding(.all)
        }
#if os(macOS)
        .padding(.all)
#endif
        .navigationTitle(account.name.isEmpty ? String(localized: "Account") : account.name)
        .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button {
                                showAddSnapshot = true
                            } label: {
                                Image(systemName: "plus")
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
    return AccountDetailView(account: account)
}

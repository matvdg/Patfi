import SwiftUI
import SwiftData

struct AccountDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var account: Account
    
    @State private var showAddSnapshot = false
    @State private var showDeleteAccountConfirm = false
    @State private var snapshots: [BalanceSnapshot] = []
    @State private var period: Period = .months
    
    let repo = BalanceRepository()
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Form {
                // MARK: - Account info & editing
                Section("Account") {
                    TextField("Name", text: $account.name)
                        .disableAutocorrection(true)
                    
                    HStack {
                        Circle().fill(account.category.color).frame(width: 10, height: 10)
                        Picker("Category", selection: $account.category) {
                            ForEach(Category.allCases) { c in
                                Text(c.localizedName)
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
                            deleteAccount()
                        }
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("This will also delete all its balances")
                    }
                }
                
                // MARK: - Bank
                Section("Bank") {
                    NavigationLink {
                        BanksView(selectedBank: $account.bank)
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
                                        Text(period.title).tag(period)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .padding()
                                TotalChartView(snapshots: snapshots, period: $period)
                                Spacer()
                            }
                        } label: {
                            VStack {
                                Picker("", selection: $period) {
                                    ForEach(Period.allCases) { period in
                                        Text(period.title).tag(period)
                                    }
                                }
                                .pickerStyle(.segmented)
                                TotalChartView(snapshots: snapshots, period: $period)
                                    .frame(height: 150)
                            }
                            
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
                                    deleteSnapshot(snap)
                                } label: { Label("Delete", systemImage: "trash") }
                            }
                            .contextMenu {
                                Button(role: .destructive) {
                                    deleteSnapshot(snap)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    } else {
                        ContentUnavailableView("No snapshots", systemImage: "clock.arrow.circlepath", description: Text("AddBalance"))
                    }
                }
                .padding(.all)
                Color.clear
                    .frame(height: 100)
                    .listRowBackground(Color.clear)
            }
            .scrollIndicators(.hidden)
#if os(macOS)
            .padding(.all)
#endif
            .navigationTitle(account.name.isEmpty ? String(localized: "Account") : account.name)
            Button(action: {
                showAddSnapshot = true
            }, label: {
                Label("Add balance", systemImage: "plus")
#if os(iOS) || os(tvOS) || os(visionOS)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.accentColor)
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    )
#endif
            })
            .padding(20)
            .sheet(isPresented: $showAddSnapshot) {
                AddBalanceView(account: account)
            }
            .onChange(of: account.balances) {
                snapshots = account.balances ?? []
            }
            .onAppear {
                snapshots = account.balances ?? []
            }
        }
    }
    
    // MARK: - Actions
    private func deleteAccount() {
        // Delete all snapshots first (defensive, even with cascade)
        if let snaps = account.balances {
            for s in snaps { context.delete(s) }
        }
        context.delete(account)
        try? context.save()
        dismiss()
    }
    
    private func deleteSnapshot(_ snap: BalanceSnapshot) {
        context.delete(snap)
        try? context.save()
    }
    
    
}

#Preview {
    AccountDetailView(account: Account(name: "BoursoBank", category: .savings))
}

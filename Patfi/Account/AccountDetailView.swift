import SwiftUI
import SwiftData

struct AccountDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var account: Account
    
    @State private var showingAddSnapshot = false
    @State private var showDeleteAccountConfirm = false
    @State private var snapshots: [BalanceSnapshot] = []
    
    let repo = BalanceRepository()
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading) {
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
                                BankRow(bank: bank)
                            } else {
                                Text("Select/create/modify a bank")
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    
                    // MARK: - Balances timeline
                    Section {
                        if let snaps = account.balances, !snaps.isEmpty {
                            NavigationLink {
                                VStack {
                                    TotalChartView(snapshots: $snapshots)
                                    Spacer()
                                }
                            } label: {
                                DashboardTotalChartView(snapshots: $snapshots)
                            }
                            List {
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
                            }
                        } else {
                            ContentUnavailableView("No snapshots", systemImage: "clock.arrow.circlepath", description: Text("AddBalance"))
                        }
                    } header: {
                        Text("Balances")
                    } footer: {
                        if let last = account.balances?.max(by: { $0.date < $1.date }) {
                            Text("Latest: \(last.date.toString) – \(last.balance.toString)")
                        }
                    }
                    .padding(.all)
                }
                #if os(macOS)
                .padding(.all)
                #endif
                .navigationTitle(account.name.isEmpty ? String(localized: "Account") : account.name)
            }
            Button(action: {
                showingAddSnapshot = true
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
            .sheet(isPresented: $showingAddSnapshot) {
                AddBalanceView(account: account)
            }
            .onChange(of: account) {
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

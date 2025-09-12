import SwiftUI
import SwiftData

struct AccountDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var account: Account
    
    @State private var showingAddSnapshot = false
    @State private var showDeleteAccountConfirm = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Form {
                // MARK: - Account info & editing
                Section("Account") {
                    TextField("Name", text: $account.name)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                    
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
                        Text("This will also delete all its balance snapshots.")
                    }
                }
                
                // MARK: - Balances timeline
                Section {
                    if let snaps = account.balances, !snaps.isEmpty {
                        List {
                            ForEach(snaps.sorted(by: { $0.date > $1.date })) { snap in
                                HStack {
                                    Text(dateString(snap.date))
                                    Spacer()
                                    Text(formatCurrency(snap.balance))
                                        .monospacedDigit()
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        deleteSnapshot(snap)
                                    } label: { Label("Delete", systemImage: "trash") }
                                }
                            }
                        }
                        .frame(minHeight: 100)
                    } else {
                        ContentUnavailableView("No snapshots", systemImage: "clock.arrow.circlepath", description: Text("AddBalance"))
                    }
                } header: {
                    Text("Balances")
                } footer: {
                    if let last = account.balances?.max(by: { $0.date < $1.date }) {
                        Text("Latest: \(dateString(last.date)) – \(formatCurrency(last.balance))")
                    }
                }
                
                
            }
            .navigationTitle(account.name.isEmpty ? String(localized: "Account") : account.name)
            Button(action: { showingAddSnapshot = true }) {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(18)
                    .background(
                        Circle()
                            .fill(Color.accentColor)
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    )
            }
            .padding(.trailing, 20)
            .padding(.bottom, 20)
            .sheet(isPresented: $showingAddSnapshot) {
                AddBalanceView(account: account)
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
    
    // MARK: - Formatters
    private func dateString(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df.string(from: date)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .currency
        nf.currencyCode = Locale.current.currency?.identifier ?? "EUR"
        nf.maximumFractionDigits = 2
        nf.minimumFractionDigits = 2
        return nf.string(from: NSNumber(value: amount)) ?? String(format: "%.2f", amount)
    }
}

#Preview {
    AccountDetailView(account: Account(name: "BoursoBank", category: .savings))
}

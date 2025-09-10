import SwiftUI
import SwiftData

struct AccountsDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Account.name, order: .forward) private var accounts: [Account]
    @State private var showingAddAccount = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack(alignment: .leading) {
                    totalHeader
                    if accounts.isEmpty {
                        ContentUnavailableView("No accounts", systemImage: "creditcard")
                    } else {
                        List(accounts) { account in
                            NavigationLink {
                                AccountDetailView(account: account)
                            } label: {
                                AccountRowView(account: account)
                            }
                        }
                        .listStyle(.plain)
                    }
                }
                .padding()

                Button(action: { showingAddAccount = true }) {
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
            }
            .navigationTitle("Accounts")
            .sheet(isPresented: $showingAddAccount) {
                AddAccountView()
            }
        }
    }

    private var totalHeader: some View {
        HStack {
            Text("Total")
                .font(.title)
                .bold()
            Spacer()
            Text(totalBalance.formattedAmount)
                .font(.title2)
                .bold()
        }
        .padding()
    }

    private var totalBalance: Double {
        accounts.reduce(0) { total, account in
            total + (account.latestBalance?.balance ?? 0)
        }
    }
    
}

#Preview {
    AccountsDashboardView()
        .modelContainer(for: [Account.self, BalanceSnapshot.self], inMemory: true)
}

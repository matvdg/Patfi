import SwiftUI
import SwiftData

struct BanksView: View {
    
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\Bank.name, order: .forward)]) private var banks: [Bank]
    @State private var showingAddBank = false
    @State private var bankToModify: Bank?
    @State private var refreshID = UUID()
    
    private let balanceRepository = BalanceRepository()
    private let bankRepository = BankRepository()
    
    var body: some View {
        Group {
            if banks.isEmpty {
                ContentUnavailableView {
                    Image(systemName: Bank.sfSymbol)
                } description: {
                    Text("noBank")
                } actions: {
                    Button {
                        bankToModify = nil
                        showingAddBank = true
                    } label: {
                        Label("createBank", systemImage: "plus")
                            .padding()
                    }
#if os(visionOS)
                    .buttonStyle(.borderedProminent)
#else
                    .buttonStyle(.glassProminent)
#endif
                }
            } else {
                List {
                    ForEach(banks) { bank in
                        NavigationLink {
                            EditBankView(bank: bank)
                        } label: {
                            HStack {
                                BankRow(bank: bank)
                                Spacer()
                                if let accounts = bank.accounts {
                                    let total = balanceRepository.balance(for: accounts)
                                    AmountText(amount: total)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.1)
                                }
                                
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                bankRepository.delete(bank, context: context)
                            } label: {
                                Label("delete", systemImage: "trash")
                            }
                            Button(role: .confirm) {
                                bankToModify = bank
                            } label: {
                                Label("edit", systemImage: "pencil")
                            }
                        }
                    }
                    Text("tipBank").foregroundStyle(.tertiary).italic()
                }
                .id(refreshID)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button {
                            bankToModify = nil
                            showingAddBank = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
        }
        .navigationTitle("banks")
        .sheet(item: $bankToModify, onDismiss: { refreshID = UUID() }) { bank in
            EditBankView(bank: bank)
        }
        .sheet(isPresented: $showingAddBank, onDismiss: { refreshID = UUID() }) {
            EditBankView()
        }
    }
}

#Preview {
    BanksView()
        .modelContainer(ModelContainer.shared)
}

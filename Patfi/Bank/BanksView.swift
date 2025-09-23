import SwiftUI
import SwiftData
import TipKit

struct BanksView: View {
    
    @Binding var selectedBank: Bank?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\Bank.name, order: .forward)]) private var banks: [Bank]
    @State private var showingAddBank = false
    @State private var bankToModify: Bank?
    @State private var refreshID = UUID()

        
    var body: some View {
        NavigationStack {
            if banks.isEmpty {
                ContentUnavailableView(
                    "No banks",
                    systemImage: "building.columns",
                    description: Text("Create your first bank")
                )
                .padding()
            } else {
                let bankTip = BankTip()
                List {
                    ForEach(banks) { bank in
                        Button(action: {
                            selectedBank = bank
                            dismiss()
                        }) {
                            BankRow(bank: bank)
                                .contentShape(Rectangle())
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                deleteBank(bank)
                                bankTip.invalidate(reason: .actionPerformed)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            Button(role: .confirm) {
                                bankToModify = bank
                                bankTip.invalidate(reason: .actionPerformed)
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                deleteBank(bank)
                                bankTip.invalidate(reason: .actionPerformed)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            Button(role: .confirm) {
                                bankToModify = bank
                                bankTip.invalidate(reason: .actionPerformed)
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                        }
                    }
                }
                .id(refreshID)
                .popoverTip(bankTip, arrowEdge: .trailing)
#if os(iOS) || os(tvOS) || os(visionOS)
                .listStyle(.insetGrouped)
#endif
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 0)
                }
            }
        }
        .navigationTitle("Banks")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    bankToModify = nil
                    showingAddBank = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(item: $bankToModify, onDismiss: { refreshID = UUID() }) { bank in
            BankView(bank: bank)
        }
        .sheet(isPresented: $showingAddBank, onDismiss: { refreshID = UUID() }) {
            BankView()
        }

    }
    
    private func deleteBank(_ bank: Bank) {
        context.delete(bank)
        do {
            try context.save()
        } catch {
            // Handle the error appropriately in a real app
            print("Failed to delete banks: \(error.localizedDescription)")
        }
    }
}

#Preview {
    BanksView(selectedBank: .constant(nil))
}

struct BankTip: Tip {
    
    var title: Text {
        Text("tipBankTitle")
    }
    
    var message: Text? {
        Text("tipBankDescription")
    }
    
    var image: Image? {
        Image(systemName: "trash")
    }
    
    var options: [Option] {
        MaxDisplayCount(3)
    }
}

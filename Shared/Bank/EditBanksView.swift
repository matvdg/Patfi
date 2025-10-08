import SwiftUI
import SwiftData

struct EditBanksView: View {
    
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
                ContentUnavailableView {
                    Image(systemName: Bank.sfSymbol)
                } description: {
                    Text("No bank")
                } actions: {
                    Button {
                        bankToModify = nil
                        showingAddBank = true
                    } label: {
                        Label("Create your first bank", systemImage: "plus")
                            .padding()
                    }
                    .buttonStyle(.glassProminent)
                }
            } else {
                List {
                    ForEach(banks) { bank in
                        Button(action: {
                            selectedBank = bank
                            dismiss()
                        }) {
                            HStack {
                                BankRow(bank: bank)
                                Spacer()
                                if selectedBank == bank {
                                    Image(systemName: "checkmark")
                                        .bold()
                                        .foregroundColor(.primary)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                deleteBank(bank)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            Button(role: .confirm) {
                                bankToModify = bank
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                        }
                        #if !os(watchOS)
                        .contextMenu {
                            Button(role: .destructive) {
                                deleteBank(bank)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            Button(role: .confirm) {
                                bankToModify = bank
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                        }
                        #endif
                    }
                    #if !os(watchOS)
                    .listRowSeparator(.hidden)
                    #endif
                    Text("tipBank").foregroundStyle(.tertiary).italic()
                }
                .id(refreshID)
                #if os(iOS) || os(tvOS) || os(visionOS)
                .listStyle(.insetGrouped)
                #endif
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 0)
                }
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
        .navigationTitle("Banks")
        .sheet(item: $bankToModify, onDismiss: { refreshID = UUID() }) { bank in
            EditBankView(bank: bank)
        }
        .sheet(isPresented: $showingAddBank, onDismiss: { refreshID = UUID() }) {
            EditBankView()
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
    NavigationStack {
        EditBanksView(selectedBank: .constant(nil))
            .modelContainer(ModelContainer.getSharedContainer())
    }
}

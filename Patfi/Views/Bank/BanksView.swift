import SwiftUI
import SwiftData

struct BanksView: View {
    
    @Binding var selectedBank: Bank?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\Bank.name, order: .forward)]) private var banks: [Bank]
    @State private var showingAddBank = false

        
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
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            NavigationLink(destination: AddBankView(bank: bank)) {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 0)
                }
            }
        }
        .navigationTitle("Banks")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddBank = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddBank) {
            AddBankView()
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

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
    
    private let bankRepository = BankRepository()

    var body: some View {
        NavigationStack {
            if banks.isEmpty {
                ContentUnavailableView {
                    Image(systemName: Bank.sfSymbol)
                } description: {
                    Text("NoBank")
                } actions: {
                    Button {
                        bankToModify = nil
                        showingAddBank = true
                    } label: {
                        Label("CreateBank", systemImage: "plus")
                            .padding()
                    }
                    .modifier(ButtonStyleModifier(isProminent: true))
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
                                bankRepository.delete(bank, context: context)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            if #available(iOS 26, watchOS 26, *) {
                                Button(role: .confirm) {
                                    bankToModify = bank
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                            } else {
                                // Fallback on earlier versions
                                Button {
                                    bankToModify = bank
                                } label: {
                                    Image(systemName: "checkmark")
                                }
                                .modifier(ButtonStyleModifier(isProminent: true))
                            }
                        }
                        #if !os(watchOS)
                        .contextMenu {
                            Button(role: .destructive) {
                                bankRepository.delete(bank, context: context)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            if #available(iOS 26, watchOS 26, *) {
                                Button(role: .confirm) {
                                    bankToModify = bank
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                            } else {
                                // Fallback on earlier versions
                                Button {
                                    bankToModify = bank
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .modifier(ButtonStyleModifier(isProminent: true))
                            }
                        }
                        #endif
                    }
                    #if !os(watchOS)
                    .listRowSeparator(.hidden)
                    #endif
                    Text("TipBank").foregroundStyle(.tertiary).italic()
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
                            if #available(iOS 26, *) {
                                Image(systemName: "plus")
                            } else {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 28))
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Banks")
        .navigationDestination(isPresented: $showingAddBank, destination: {
            EditBankView()
        })
        .navigationDestination(item: $bankToModify, destination: { bank in
            EditBankView(bank: bank)
        })
        .onChange(of: showingAddBank) { _, newValue in
            if newValue == false {
                refreshID = UUID()
            }
        }
        .onChange(of: bankToModify) { _, newValue in
            refreshID = UUID()
        }
    }
}

#Preview {
    NavigationStack {
        EditBanksView(selectedBank: .constant(nil))
            .modelContainer(ModelContainer.shared)
    }
}

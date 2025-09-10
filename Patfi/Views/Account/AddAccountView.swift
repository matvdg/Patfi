import SwiftUI
import SwiftData

struct AddAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\Bank.name, order: .forward)]) private var banks: [Bank]

    @State private var name: String = ""
    @State private var category: Category = .other
    @State private var initialBalanceText: String = ""
    @State private var selectedBank: Bank? = nil
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section("Account") {
                    TextField("Name", text: $name)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                    HStack {
                        Circle().fill(category.color).frame(width: 10, height: 10)
                        Picker("Category", selection: $category) {
                            ForEach(Category.allCases) { c in
                                Text(c.localizedName)
                                .tag(c)
                            }
                        }
                    }
                }
                
                Section("Bank") {
                    // Picker with custom rows matching the bank design
                    if banks.isEmpty {
                        NavigationLink("Manage banks") { BanksView() }
                    } else {
                        Picker(selectedBank == nil ? "Select bank" : "", selection: $selectedBank) {
                            ForEach(banks) { bank in
                                BankRow(bank: bank)
                                    .tag(bank as Bank?)
                            }
                        }
                        .pickerStyle(.navigationLink)
                        NavigationLink("Manage banks") { BanksView() }
                    }
                }
                
                Section("Initial balance") {
                    TextField("0.00", text: $initialBalanceText)
                        .keyboardType(.decimalPad)
                        .focused($focused)
                        .onChange(of: initialBalanceText) { _, newValue in
                            let cleaned = newValue.filter { !$0.isWhitespace }
                            if cleaned != newValue {
                                initialBalanceText = cleaned
                            }
                        }
                }
            }
            .navigationTitle("New Account")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { create() }
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedBank == nil)
                }
            }
            .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { focused = true } }
        }
    }

    private func create() {
        let account = Account(name: name, category: category, bank: selectedBank)
        context.insert(account)

        if let amount = Double(initialBalanceText.replacingOccurrences(of: ",", with: ".")) {
            let snap = BalanceSnapshot(date: Date(), balance: amount, account: account)
            context.insert(snap)
        }

        do { try context.save() } catch { print("Save error:", error) }
        dismiss()
    }

}

#Preview {
    AddAccountView()
}

import SwiftUI
import SwiftData

struct AddAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var name: String = ""
    @State private var category: Category = .other
    @State private var initialBalanceText: String = ""
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
                Section("Initial balance") {
                    TextField("0.00", text: $initialBalanceText)
                        .keyboardType(.decimalPad)
                        .focused($focused)
                }
            }
            .navigationTitle("New Account")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { create() }
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { focused = true } }
        }
    }

    private func create() {
        let account = Account(name: name, category: category)
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

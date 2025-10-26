import SwiftUI
import SwiftData

struct AddAccountView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\Bank.name, order: .forward)]) private var banks: [Bank]
    
    @State private var name: String = ""
    @State private var category: Category = .other
    @State private var balance: Double?
    @State private var bank: Bank? = nil
    @FocusState private var focused: Bool
    
    let accountRepository = AccountRepository()
    
    var body: some View {
        Form {
            Section("Account") {
                TextField("Name", text: $name)
#if !os(macOS)
                    .textInputAutocapitalization(.words)
#endif
                    .autocorrectionDisabled()
                Picker("Category", selection: $category) {
                    ForEach(Category.allCases) { c in
                        HStack {
                            Circle().fill(c.color).frame(width: 10, height: 10)
                            Text(c.localized)
                        }
                        .tag(c)
                    }
                }
#if !os(macOS)
                .pickerStyle(.navigationLink)
#endif
            }
            
            Section("Bank") {
                NavigationLink {
                    EditBanksView(selectedBank: $bank)
                } label: {
                    if let bank {
                        BankRow(bank: bank)
                    } else {
                        Text("SelectBank")
                            .foregroundColor(.primary)
                    }
                }
            }
            
            Section("Balance") {
                AmountTextField(amount: $balance, signMode: category == .loan ? .negativeOnly : .both)
                    .focused($focused)
                    .onChange(of: category) { _, new in
                        if new == .loan {
                            balance = nil
                        }
                    }
            }
        }
        .navigationTitle("AddAccount")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(role: .confirm, action: {
                    guard let bank, let balance else { return }
                    accountRepository.create(name: name, balance: balance, category: category, bank: bank, context: context)
                    dismiss()
                    
                })
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || bank == nil || balance == nil)
            }
        }
        .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { focused = true } }
        .formStyle(.grouped)
    }
}

#Preview {
    NavigationStack {
        AddAccountView()
    }
}

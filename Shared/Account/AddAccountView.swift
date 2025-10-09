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
    
    let accountRepository = AccountRepository()
    
    var balance: Double? {
        Double(initialBalanceText.replacingOccurrences(of: ",", with: "."))
    }
    
    var body: some View {
        Form {
            Section("Account") {
                TextField("Name", text: $name)
                #if !os(macOS)
                    .textInputAutocapitalization(.words)
                #endif
                    .autocorrectionDisabled()
                    .frame(maxWidth: 300)
                HStack {
                    Circle().fill(category.color).frame(width: 10, height: 10)
                    Picker("Category", selection: $category) {
                        ForEach(Category.allCases) { c in
                            Text(c.localized)
                                .tag(c)
                        }
                    }
                }
            }
            
            Section("Bank") {
                NavigationLink {
                    EditBanksView(selectedBank: $selectedBank)
                } label: {
                    if let bank = selectedBank {
                        BankRow(bank: bank)
                    } else {
                        Text("Select/create/modify a bank")
                            .foregroundColor(.primary)
                    }
                }
            }
            
            Section("Initial balance") {
                TextField("Amount", text: $initialBalanceText)
#if os(iOS) || os(tvOS) || os(visionOS)
                    .keyboardType(.decimalPad)
#endif
                    .focused($focused)
                    .frame(maxWidth: 300)
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
            ToolbarItem(placement: .confirmationAction) {
                Button(role: .confirm, action: {
                    guard let bank = selectedBank, let balance = balance else { return }
                    accountRepository.create(name: name, balance: balance, category: category, bank: bank, context: context)
                    dismiss()
                    
                })
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedBank == nil || balance == nil)
            }
        }
        .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { focused = true } }
        .formStyle(.grouped)
    }
}

#Preview {
    AddAccountView()
}

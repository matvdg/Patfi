import SwiftUI
import SwiftData

struct AddAccountView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\Bank.name, order: .forward)]) private var banks: [Bank]
    
    @State private var name: String = ""
    @State private var category: Category = .other
    @State private var initialBalanceText: String = ""
    @State private var bank: Bank? = nil
    @FocusState private var focused: Bool
    
    let accountRepository = AccountRepository()
    
    var balance: Double? {
        Double(initialBalanceText.replacingOccurrences(of: ",", with: "."))
    }
    
    var body: some View {
        Form {
            Section("account") {
                TextField("name", text: $name)
#if !os(macOS)
                    .textInputAutocapitalization(.words)
#endif
                    .autocorrectionDisabled()
                Picker("category", selection: $category) {
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
            
            Section("bank") {
                NavigationLink {
                    EditBanksView(selectedBank: $bank)
                } label: {
                    if let bank {
                        BankRow(bank: bank)
                    } else {
                        Text("selectBank")
                            .foregroundColor(.primary)
                    }
                }
            }
            
            Section("initialBalance") {
                
#if os(watchOS)
                NavigationLink {
                    NumericalKeyboardView(text: $initialBalanceText)
                } label: {
                    Text(initialBalanceText.isEmpty ? String(localized:"balance") : initialBalanceText)
                }
#else
                TextField("balance", text: $initialBalanceText)
#if os(iOS) || os(tvOS) || os(visionOS)
                    .keyboardType(.decimalPad)
#endif
                    .focused($focused)
                    .onChange(of: initialBalanceText) { _, newValue in
                        let cleaned = newValue.filter { !$0.isWhitespace }
                        if cleaned != newValue {
                            initialBalanceText = cleaned
                        }
                    }
#endif
            }
        }
        .navigationTitle("addAccount")
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

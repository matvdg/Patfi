import SwiftUI
import SwiftData

struct AddExpenseView: View {
    
    init(account: Account? = nil) {
        _selectedAccountID = State(initialValue: account?.persistentModelID)
    }
    
    @FocusState private var focused: Bool
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @AppStorage("isMentalMathModeEnabled") private var isMentalMathModeEnabled = false
    
    @Query(sort: \Account.name, order: .forward) private var accounts: [Account]
    
    @State private var title: String = ""
    @State private var paymentMethod: Transaction.PaymentMethod = .applePay
    @State private var expenseCategory: Transaction.ExpenseCategory?
    @State private var amount: Double?
    @State private var selectedAccountID: PersistentIdentifier?
    @State private var date: Date = .now
    @State private var manualResult: Double?
    @State private var isSaveDisabled: Bool = false
    @State private var isCheckButtonPressed: Bool = false
    
    private var selectedAccount: Account? {
        accounts.first(where: { $0.persistentModelID == selectedAccountID })
    }
    
    private var isMentalMathCorrect: Bool {
        guard let account = selectedAccount, let manualResult, let amount else { return false }
        let result = account.latestBalance - abs(amount)
        if manualResult.isAlmostEqual(to: result) {
            return true
        } else {
            return false
        }
    }
    
    let transactionRepository =  TransactionRepository()
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Expense")
                    Spacer()
                    AmountTextField(amount: $amount, signMode: .negativeOnly)
                        .focused($focused)
                        .onChange(of: amount) {
                            isCheckButtonPressed = false
                        }
                }
                TextField("Description", text: $title)
#if !os(macOS)
                    .textInputAutocapitalization(.words)
#endif
                    .autocorrectionDisabled()
                AccountPicker(id: $selectedAccountID, title: String(localized: "Account"))
                PaymentMethodPicker(paymentMethod: $paymentMethod)
                ExpenseCategoryPicker(expenseCategory: $expenseCategory)
                    .onChange(of: expenseCategory) {
                        isCheckButtonPressed = false
                    }
                DatePicker("Date", selection: $date, displayedComponents: [.date])
#if !os(macOS)
                Toggle("MentalMathMode", isOn: $isMentalMathModeEnabled)
#endif
            } footer: {
                if let account = selectedAccount {
                    if let amount, isMentalMathModeEnabled {
                        let balance = account.latestBalance
                        VStack(alignment: .trailing, spacing: 16) {
                            AmountText(amount: balance)
                            AmountText(amount: amount)
                            Divider()
                                .frame(height: 2)
                                .background(Color.primary)
                            let result = balance - abs(amount)
                            MentalMathTextField(amount: $manualResult, signMode: result >= 0 ? .positiveOnly : .negativeOnly, placeholder: String(localized: "Result"))
                                .multilineTextAlignment(.trailing)
                                .onChange(of: manualResult) {
                                    isCheckButtonPressed = false
                                }
                            HStack(alignment: .center, spacing: 8) {
                                Spacer()
                                CheckButton(isMentalMathCorrect: isMentalMathCorrect, isPressed: $isCheckButtonPressed)
                                    .onChange(of: isCheckButtonPressed) {
                                        isSaveDisabled = !isMentalMathCorrect
                                    }
#if os(watchOS)
                                    .font(.system(size: 15))
#endif
                                Spacer()
                            }
                            .padding()
                            .font(.title)
                            .disabled(manualResult == nil)
                            .opacity(manualResult == nil ? 0 : 1)
                        }
#if os(watchOS)
                        .font(.system(size: 20))
#else
                        .padding().padding()
                        .font(.system(size: 30, weight: .bold, design: .monospaced))
#endif
                    } else {
                        let balance = account.latestBalance
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                if let bank = account.bank {
                                    Text(bank.name)
                                    Text(" • ")
                                }
                                Text(account.name)
                            }
                            if let amount {
                                Text("PreviousBalance \(balance.currencyAmount) newBalance \((balance - abs(amount)).currencyAmount)")
                            } else {
                                Text("Balance: \(balance.currencyAmount)")
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("AddExpense")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if #available(iOS 26, watchOS 26, *) {
                    Button(role: .confirm, action: {
                        guard let amount, let selectedAccount, let expenseCategory else { return }
                        transactionRepository.addExpense(title: title, amount: amount, account: selectedAccount, paymentMethod: paymentMethod, expenseCategory: expenseCategory, date: date, context: context)
                        dismiss()
                    })
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedAccount == nil || amount == nil || amount == 0 || expenseCategory == nil || isSaveDisabled)
                } else {
                    // Fallback on earlier versions
                    Button {
                        guard let amount, let selectedAccount, let expenseCategory else { return }
                        transactionRepository.addExpense(title: title, amount: amount, account: selectedAccount, paymentMethod: paymentMethod, expenseCategory: expenseCategory, date: date, context: context)
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .modifier(ButtonStyleModifier())
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedAccount == nil || amount == nil || amount == 0 || expenseCategory == nil || isSaveDisabled)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { focused = true }
            isSaveDisabled = isMentalMathModeEnabled
        }
        .formStyle(.grouped)
        .onChange(of: accounts, initial: true) { _, newAccounts in
            if selectedAccountID == nil,
               let defaultAccount = newAccounts.first(where: { $0.isDefault }) {
                selectedAccountID = defaultAccount.persistentModelID
            }
        }
        .onChange(of: isMentalMathModeEnabled) { oldValue, newValue in
            isSaveDisabled = newValue
            isCheckButtonPressed = false
        }
    }
}

#Preview {
    NavigationStack{
        AddExpenseView()
    }
    .modelContainer(ModelContainer.shared)
}

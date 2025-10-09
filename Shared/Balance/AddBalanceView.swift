import SwiftUI
import SwiftData

struct AddBalanceView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    var account: Account

    @State private var date: Date = .now
    @State private var amountText: String = ""
    @FocusState private var focused: Bool
    let balanceRepository = BalanceRepository()

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $date, displayedComponents: [.date])
                TextField("Balance", text: $amountText)
                    #if os(iOS) || os(tvOS) || os(visionOS)
                    .keyboardType(.decimalPad)
                    #endif
                    .focused($focused)
                    .onChange(of: amountText) { _, newValue in
                        let cleaned = newValue.filter { !$0.isWhitespace }
                        if cleaned != newValue {
                            amountText = cleaned
                        }
                    }
            }
            #if os(macOS)
            .padding()
            #endif
            .navigationTitle(String(localized: "New snapshot"))
            .toolbar {
                #if !os(watchOS)
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel, action: { dismiss() })
                }
                #endif
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        guard let amount = Double(amountText.replacingOccurrences(of: ",", with: ".")) else { return }
                        balanceRepository.add(amount: amount, date: date, account: account, context: context)
                        dismiss()
                    }
                    .disabled(Double(amountText.replacingOccurrences(of: ",", with: ".")) == nil)
                }
            }
            .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { focused = true } }
        }
    }
}

#Preview {
    AddBalanceView(account: Account(name: "BoursoBank", category: .savings))
}

import SwiftUI
import SwiftData

struct AddBalanceView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    var account: Account

    @State private var date: Date = .now
    @State private var amountText: String = ""
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $date, displayedComponents: [.date])
                TextField("Amount", text: $amountText)
                    .keyboardType(.decimalPad)
                    .focused($focused)
                    .onChange(of: amountText) { _, newValue in
                        let cleaned = newValue.filter { !$0.isWhitespace }
                        if cleaned != newValue {
                            amountText = cleaned
                        }
                    }
            }
            .navigationTitle(String(localized: "New snapshot"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { add() }
                        .disabled(Double(amountText.replacingOccurrences(of: ",", with: ".")) == nil)
                }
            }
            .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { focused = true } }
        }
    }

    private func add() {
        guard let amount = Double(amountText.replacingOccurrences(of: ",", with: ".")) else { return }
        let snap = BalanceSnapshot(date: Calendar.current.startOfDay(for: date), balance: amount, account: account)
        context.insert(snap)
        try? context.save()
        dismiss()
    }
}

#Preview {
    AddBalanceView(account: Account(name: "BoursoBank", category: .savings))
}

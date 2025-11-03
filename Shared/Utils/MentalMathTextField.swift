import SwiftUI

struct MentalMathTextField: View {
    
    @Binding var amount: Double?
    
    var signMode: SignMode = .both
#if os(macOS)
    var placeholder: String = ""
#else
    var placeholder: String = String(localized: "Amount")
#endif
    
    @State private var textValue: String = ""
    @State var isPositive = true
    @State private var isProgrammaticChange = false
    
    @FocusState private var isEditing: Bool
    
    private let decimalSeparator: String = Locale.current.decimalSeparator ?? "."
    
    var body: some View {
#if os(watchOS)
        NavigationLink {
            NumericalKeyboardView(amount: $amount, signMode: signMode)
        } label: {
            AmountText(amount: amount, placeholder: placeholder)
        }
#else
        VStack(alignment: .trailing, spacing: 20) {
            HStack {
                HStack(spacing: 0) {
                    if !isPositive, !textValue.isEmpty {
                        Text("-")
                    }
                    TextField(placeholder, text: $textValue)
                        .tint(.clear)
                        .frame(maxWidth: placeholder == String(localized: "Result") ? .infinity : 150)
                        .multilineTextAlignment(.trailing)
                        .textFieldStyle(.plain)
                        .focused($isEditing)
#if !os(macOS)
                        .keyboardType(.decimalPad)
#endif
                        .onAppear {
                            textValue = formattedAmount(amount, withSymbol: true)
                        }
                        .onChange(of: textValue) { old, new in
                            guard isEditing, !isProgrammaticChange else {
                                isProgrammaticChange = false
                                return
                            }
                            handleInput(old: old, new: new)
                            updateAmountFromInput()
                        }
                        .onChange(of: isEditing) { _, editing in
                            if !editing {
                                textValue = formattedAmount(amount, withSymbol: true)
                            } else {
                                textValue = formattedAmount(amount, withSymbol: false)
                            }
                        }
                }
                .fixedSize()
                .frame(maxWidth: .infinity, alignment: .trailing)
                .foregroundColor(color(for: amount))
                .bold()
                if isEditing {
                    Button {
                        isEditing = false
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .bold()
                            .imageScale(.large)
                    }
                }
            }
            .onAppear {
                if let amount {
                    isPositive = amount >= 0
                }
            }
            if signMode == .both {
                Divider()
                Toggle("OverdrawnAccount", isOn: Binding(
                    get: { !isPositive },
                    set: { _,_ in
                        isPositive.toggle()
                        if let amt = amount {
                            amount = -amt
                        }
                    }
                ))
            }
        }
#endif
    }
    
    
    private func handleInput(old: String, new: String) {
        
        // ⌫ Remove first character if necessary
        guard new.count != old.count - 1 else {
            isProgrammaticChange = true
            var updated = old
            updated.removeFirst()
            textValue = updated
            return
        }
        
        var updatedInput = textValue
        
        // Invert for mental math mode (right to left)
        if updatedInput.count > 1 {
            isProgrammaticChange = true
            let last = updatedInput.removeLast()
            updatedInput.insert(last, at: textValue.startIndex)
        }
        
        // Prevents forbidden digits (everything excepts numerical digits)
        if Double(updatedInput.cleanComa) == nil, !updatedInput.isEmpty {
            isProgrammaticChange = true
            updatedInput.removeFirst()
        }
        
        // Remove manual decimal separator
        if updatedInput.cleanComa.hasPrefix(".") {
            isProgrammaticChange = true
            if updatedInput.count == 3 {
                updatedInput = updatedInput.withLocaleDecimalSeparator
            } else {
                updatedInput.removeFirst()
            }
        }
        
        // Auto decimalSepator
        if updatedInput.count == 3 && !updatedInput.contains(decimalSeparator) {
            isProgrammaticChange = true
            let first = updatedInput.removeFirst()
            updatedInput.insert(decimalSeparator.first!, at: updatedInput.startIndex)
            updatedInput.insert(first, at: updatedInput.startIndex)
        }
        
        // Maximum 10 caracters
        if updatedInput.count > 10 {
            isProgrammaticChange = true
            updatedInput.removeFirst()
        }
        
        // If cast still fails (edge cases such as moving the cursor), remove everything
        if Double(updatedInput.cleanComa) == nil, !updatedInput.isEmpty {
            isProgrammaticChange = true
            updatedInput.removeAll()
        }
        
        textValue = updatedInput
        if new == updatedInput { isProgrammaticChange = false }
    }
    
    private func updateAmountFromInput() {
        guard let number = Double(textValue.cleanComa), textValue != "." else {
            amount = nil
            return
        }
        let absValue = abs(number)
        switch signMode {
        case .positiveOnly:
            amount = absValue
            isPositive = true
        case .negativeOnly:
            amount = -absValue
            isPositive = false
        case .both:
            amount = isPositive ? absValue : -absValue
        }
    }
    
    private func formattedAmount(_ value: Double?, withSymbol: Bool) -> String {
        guard let value else { return "" }
        let formatter = NumberFormatter.getCurrencyFormatter()
        if !withSymbol {
            formatter.currencySymbol = ""
        }
        let result = formatter.string(from: NSNumber(value: abs(value)))?.trimmingCharacters(in: .whitespaces) ?? ""
        return withSymbol ? result : result.cleanSpaces
    }
    
    private func color(for value: Double?) -> Color {
        guard let v = value else { return .primary }
        return v > 0 ? .green : (v < 0 ? .red : .primary)
    }
}

#Preview {
    @Previewable @State var amount: Double? = nil
    NavigationStack {
        Form {
            Section("SignMode: positiveOnly") {
                MentalMathTextField(amount: $amount, signMode: .positiveOnly)
            }
            Section("SignMode: negativeOnly") {
                MentalMathTextField(amount: $amount, signMode: .negativeOnly)
            }
        }
    }
    .navigationTitle("Demo Form")
}

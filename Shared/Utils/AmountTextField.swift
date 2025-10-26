import SwiftUI

struct AmountTextField: View {
    @Binding var amount: Double?
    var signMode: SignMode = .both
    @State private var textValue: String = ""
    @State var isPositive = true
    @FocusState private var isEditing: Bool
    
    private let decimalSeparator: String = Locale.current.decimalSeparator ?? "."
    
    var body: some View {
#if os(watchOS)
        NavigationLink {
            NumericalKeyboardView(amount: $amount, signMode: signMode)
        } label: {
            AmountText(amount: amount)
        }
#else
        VStack(spacing: 20) {
            HStack {
                HStack(spacing: 0) {
#if !os(macOS)
                    if !isPositive, !textValue.isEmpty {
                        Text("-")
                    }
#endif
                    TextField("Amount", text: $textValue)
                        .focused($isEditing)
#if !os(macOS)
                        .keyboardType(.decimalPad)
#endif
                        .onAppear {
                            textValue = formattedAmount(amount, withSymbol: true)
                        }
                        .onChange(of: textValue) {
                            guard isEditing else { return }
                            handleInput()
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
    
    private func handleInput() {
        // Maximum 7 integer digits (X XXX XXX.XX)
        let parts = textValue.split(separator: decimalSeparator, omittingEmptySubsequences: false)
        let integerPartCount = parts.first?.count ?? 0
        if integerPartCount > 7 && !textValue.cleanComa.contains(".") {
            textValue.removeLast()
        }
        // Prevents 0X (00 -> 0, 06 -> 6, 0.6 -> 0.6)
        if textValue.count > 1 && textValue.hasPrefix("0") && !textValue.cleanComa.hasPrefix("0.") {
            textValue.removeFirst()
        }
        // Add 0 before .
        if textValue.cleanComa.hasPrefix(".") {
            textValue = "0\(decimalSeparator)"
        }
        
        // Convert . into decimalSeparator
        if textValue.hasSuffix(".") {
            textValue.removeLast()
            textValue.append(decimalSeparator)
        }
        
        // Prevents more than two decimal digits (0.999 -> 0.99)
        if let dotIndex = textValue.firstIndex(of: Character("\(decimalSeparator)")) ?? textValue.firstIndex(of: Character(".")) {
            let decimals = textValue[dotIndex...].dropFirst()
            if decimals.count > 2 {
                textValue.removeLast()
            }
        }
        // Prevents forbidden digits (everything excepts numerical digits)
        if Double(textValue.cleanComa) == nil, !textValue.isEmpty {
            textValue.removeLast()
        }
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
    @Previewable @State var amount0: Double? = nil
    @Previewable @State var amount1: Double? = 0
    @Previewable @State var amount2: Double? = 56.78
    @Previewable @State var amount3: Double? = -22
    NavigationStack {
        Form {
            Section("SignMode: both") {
                AmountTextField(amount: $amount0)
                AmountTextField(amount: $amount1)
                AmountTextField(amount: $amount2)
                AmountTextField(amount: $amount3)
            }
            Section("SignMode: positiveOnly") {
                AmountTextField(amount: $amount2, signMode: .positiveOnly)
            }
            Section("SignMode: negativeOnly") {
                AmountTextField(amount: $amount3, signMode: .negativeOnly)
            }
        }
    }
    .navigationTitle("Demo Form")
}

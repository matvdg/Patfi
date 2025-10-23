import SwiftUI
import WatchKit

enum SignMode {
    case positiveOnly
    case negativeOnly
    case both
}

struct NumericalKeyboardView: View {
    
    private let currencySymbol: String = Locale.current.currencySymbol ?? "€"
    @Environment(\.dismiss) private var dismiss
    @Binding var text: String
    @State var isPositive = true
    var signMode: SignMode = .both
    
    private let decimalSeparator: String = Locale.current.decimalSeparator ?? "."
    private var keys: [[String]] {
        [
            ["1","2","3", "4"],
            ["5","6","7","8"],
            ["9","0",decimalSeparator,"OK"]
        ]
    }
    
    // Computed property for currency formatter
    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter
    }

    // Computed property for formatted text
    private var formattedText: String {
        guard !text.isEmpty else { return text }
        let sign: String
        let numericPart: String
        if text.hasPrefix("-") {
            sign = "-"
            numericPart = String(text.dropFirst())
        } else if text.hasPrefix("+") {
            sign = "+"
            numericPart = String(text.dropFirst())
        } else {
            sign = ""
            numericPart = text
        }
        // Replace local decimal separator with dot for conversion
        let normalizedNumeric = numericPart.replacingOccurrences(of: decimalSeparator, with: ".")
        if let number = Double(normalizedNumeric) {
            if let formatted = currencyFormatter.string(from: NSNumber(value: abs(number))) {
                return sign + formatted
            }
        }
        return text
    }

    var body: some View {
        VStack(spacing: 5) {
            Text(formattedText)
                .font(.headline)
                .foregroundColor(text.hasPrefix("+") ? .green : (text.hasPrefix("-") ? .red : .primary))
                .frame(height: 20)
            ForEach(keys, id: \.self) { row in
                HStack {
                    ForEach(row, id: \.self) { key in
                        Button {
                            handleKey(key)
                        } label: {
                            if key == "OK" {
                                Image(systemName: "checkmark").bold().foregroundColor(.green)
                            } else {
                                Text(key)
                                    .font(.headline)
                            }
                        }
                        .buttonStyle(.glass)
                    }
                }
            }
        }
        .padding(13)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("", systemImage: "delete.left", role: .destructive) {
                    if !text.isEmpty { text.removeLast() }
                }.foregroundColor(.red)
            }
            ToolbarItem(placement: .topBarLeading) {
                Button("", systemImage: isPositive ? "plus.forwardslash.minus" : "minus.forwardslash.plus", role: .confirm) {
                    isPositive.toggle()
                    if text.hasPrefix("-") {
                        text = "+" + text.dropFirst()
                    } else if text.hasPrefix("+") {
                        text = "-" + text.dropFirst()
                    } else if !text.isEmpty {
                        text = "-" + text
                    }
                }
                .foregroundColor(isPositive ? .green : .red)
                .disabled(signMode != .both)
                .opacity((signMode != .both) ? 0.0 : 1.0)
            }
            
        }
    }
    
    private func handleKey(_ key: String) {
        WKInterfaceDevice.current().play(.click)
        switch key {
        case "OK":
            dismiss()
        default:
            if text.isEmpty {
                switch signMode {
                case .positiveOnly:
                    text = "+" + key
                case .negativeOnly:
                    text = "-" + key
                case .both:
                    text = (isPositive ? "+" : "-") + key
                }
            } else {
                text.append(key)
            }
        }
    }
}

#Preview {
    @Previewable @State var amount: String = "44.99"
    TabView {
        NavigationStack {
            NumericalKeyboardView(text: $amount, signMode: .both)
        }
        NavigationStack {
            NumericalKeyboardView(text: $amount, signMode: .positiveOnly)
        }
    }
}

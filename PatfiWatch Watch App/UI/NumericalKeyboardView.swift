import SwiftUI
import WatchKit

struct NumericalKeyboardView: View {
    
    private let currencySymbol: String = Locale.current.currencySymbol ?? "€"
    @Environment(\.dismiss) private var dismiss
    @Binding var text: String
    
    private let decimalSeparator: String = Locale.current.decimalSeparator ?? "."
    private var keys: [[String]] {
        [
            ["1","2","3", "4"],
            ["5","6","7","8"],
            [decimalSeparator, "9","0","+/-"]
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
        VStack(spacing: 0) {
            Text(formattedText)
                .font(.headline)
                .foregroundColor(text.hasPrefix("+") ? .green : (text.hasPrefix("-") ? .red : .primary))
                .frame(height: 20)
                .padding(.bottom, 10)
            ForEach(keys, id: \.self) { row in
                HStack {
                    ForEach(row, id: \.self) { key in
                        Button {
                            handleKey(key)
                        } label: {
                            Text(key)
                                .font(.headline)
                        }
                        .buttonStyle(.glass)
                    }
                }
            }
        }
        .padding(13)
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button("", systemImage: "delete.left", role: .destructive) {
                    if !text.isEmpty { text.removeLast() }
                }
            }
        }
    }
    
    private func handleKey(_ key: String) {
        WKInterfaceDevice.current().play(.click)
        switch key {
        case "+/-":
            if !text.isEmpty {
                if text.hasPrefix("-") {
                    // Replace leading "-" with "+"
                    text.removeFirst()
                    text = "+" + text
                } else if text.hasPrefix("+") {
                    // Replace leading "+" with "-"
                    text.removeFirst()
                    text = "-" + text
                } else if !text.isEmpty {
                    // Add "-" by default
                    text = "-" + text
                }
            }
        default:
            if text.isEmpty {
                text = "+" + key
            } else {
                text.append(key)
            }
        }
    }
}

#Preview {
    NavigationStack {
        NumericalKeyboardView(text: .constant("44"))
    }
}

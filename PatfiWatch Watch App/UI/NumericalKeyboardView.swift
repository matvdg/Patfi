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
    var signMode: SignMode = .both
    
    private let decimalSeparator: String = Locale.current.decimalSeparator ?? "."
    private var keys: [[String]] {
        [
            ["1","2","3", "4"],
            ["5","6","7","8"],
            ["9","0",decimalSeparator,"-/+"]
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
                            Text(key)
                                .font(.headline)
                        }
                        .buttonStyle(.glass)
                        .disabled(key == "-/+" && signMode != .both)
                        .opacity((key == "-/+" && signMode != .both) ? 0.5 : 1.0)
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
        case "-/+":
            if signMode == .both {
                if text.hasPrefix("-") {
                    text = "+" + text.dropFirst()
                } else if text.hasPrefix("+") {
                    text = "-" + text.dropFirst()
                } else if !text.isEmpty {
                    text = "-" + text
                }
            }
        default:
            if text.isEmpty {
                switch signMode {
                case .positiveOnly:
                    text = "+" + key
                case .negativeOnly:
                    text = "-" + key
                case .both:
                    text = "+" + key
                }
            } else {
                text.append(key)
            }
        }
    }
}

#Preview {
    NavigationStack {
        NumericalKeyboardView(text: .constant("-44.99"), signMode: .negativeOnly)
    }
}

import SwiftUI
import WatchKit

struct NumericalKeyboardView: View {
    
    private let currencySymbol: String = Locale.current.currencySymbol ?? "€"
    @Environment(\.dismiss) private var dismiss
    @Binding var amount: Double?
    @State private var inputString: String = ""
    @State var isPositive = true
    var signMode: SignMode = .both
    var displayCurrency: Bool = true
    
    private let decimalSeparator: String = Locale.current.decimalSeparator ?? "."
    private var keys: [[String]] {
        [
            ["1","2","3", "4"],
            ["5","6","7","8"],
            ["9","0",decimalSeparator,"OK"]
        ]
    }

    var body: some View {
        VStack(spacing: 5) {
            HStack(spacing: 0) {
                if !inputString.isEmpty {
                    if !isPositive {
                        Text("-")
                    }
                    let prefixSymbols: Set<String> = ["$", "£", "¥", "₹", "฿", "₩", "₦", "₱", "₫", "CHF"]
                    let symbol = currencySymbol
                    let formattedInput = inputString.replacingOccurrences(of: ".", with: decimalSeparator)
                    if !displayCurrency {
                        Text(formattedInput)
                    } else if prefixSymbols.contains(symbol) {
                        Text(symbol)
                        Text(formattedInput)
                    } else {
                        Text(formattedInput)
                        Text(" \(symbol)")
                    }
                }
            }
            .frame(height: 20)
            .bold()
            .foregroundColor(isPositive ? .green : .red)
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
                        .modifier(ButtonStyleModifier(isProminent: true))
                    }
                }
            }
        }
        .padding(13)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("", systemImage: "delete.left", role: .destructive) {
                    if !inputString.isEmpty {
                        inputString.removeLast()
                        updateAmountFromInput()
                    }
                }.foregroundColor(.red)
            }
            ToolbarItem(placement: .topBarLeading) {
                if #available(watchOS 26, *) {
                    Button("", systemImage: isPositive ? "plus.forwardslash.minus" : "minus.forwardslash.plus", role: .confirm) {
                        isPositive.toggle()
                        if let amt = amount {
                            amount = -amt
                        }
                    }
                    .foregroundColor(isPositive ? .green : .red)
                    .disabled(signMode != .both)
                    .opacity((signMode == .both) ? 1 : 0)
                } else {
                    // Fallback on earlier versions
                    Button(action: {
                        isPositive.toggle()
                        if let amt = amount {
                            amount = -amt
                        }
                    }) {
                        Image(systemName: isPositive ? "plus.forwardslash.minus" : "minus.forwardslash.plus")
                    }
                    .foregroundColor(isPositive ? .green : .red)
                    .disabled(signMode != .both)
                    .opacity((signMode == .both) ? 1 : 0)
                }
            }
            
        }
        .onAppear {
            if let amount {
                isPositive = amount >= 0
                if amount.truncatingRemainder(dividingBy: 1) == 0 {
                    inputString = String(Int(abs(amount)))
                } else {
                    inputString = String(abs(amount))
                }
            } else {
                inputString = ""
            }
        }
    }
    
    private func updateAmountFromInput() {
        guard let number = Double(inputString), inputString != "." else {
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
    
    private func handleKey(_ key: String) {
        WKInterfaceDevice.current().play(.click)
        switch key {
        case "OK":
            dismiss()
        case decimalSeparator:
            if !inputString.contains(".") {
                if inputString.isEmpty {
                    inputString = "0" + "."
                } else {
                    inputString.append(".")
                }
                updateAmountFromInput()
            }
        default:
            let parts = inputString.split(separator: ".", omittingEmptySubsequences: false)
            let integerPartCount = parts.first?.count ?? 0
            if integerPartCount >= 7 && !inputString.contains(".") {
                return
            }
            if key.allSatisfy({ $0.isNumber }) {
                if inputString == "0" {
                    inputString.removeFirst()
                }
                if let dotIndex = inputString.firstIndex(of: ".") {
                    let decimals = inputString[dotIndex...].dropFirst()
                    if decimals.count >= 2 {
                        return
                    }
                }
                inputString.append(key)
                updateAmountFromInput()
            }
        }
    }
}

#Preview {
    @Previewable @State var amount: Double? = 44.99
    TabView {
        NavigationStack {
            NumericalKeyboardView(amount: $amount, signMode: .both)
        }
        NavigationStack {
            NumericalKeyboardView(amount: $amount, signMode: .positiveOnly)
        }
    }
}

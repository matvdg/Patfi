import SwiftUI
import WatchKit

struct NumericalKeyboardView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Binding var text: String
    
    private let decimalSeparator: String = Locale.current.decimalSeparator ?? "."
    private var keys: [[String]] {
        [
            ["1","2","3", "4"],
            ["5","6","7","8"],
            [decimalSeparator, "9","0","⌫"]
        ]
    }
    
    var body: some View {
        VStack {
            Text(text)
                .font(.headline)
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
            ToolbarItem(placement: .confirmationAction) {
                Button(role: .confirm, action: {
                    dismiss()
                })
            }
        }
    }
    
    private func handleKey(_ key: String) {
        WKInterfaceDevice.current().play(.click)
        switch key {
        case "⌫":
            if !text.isEmpty { text.removeLast() }
        default:
            text.append(key)
        }
    }
}

#Preview {
    NavigationStack {
        NumericalKeyboardView(text: .constant(""))
    }
}

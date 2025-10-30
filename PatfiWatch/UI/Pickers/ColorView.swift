import SwiftUI
import SwiftData

struct ColorView: View {
    
    var bank: Bank
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
            ForEach(Bank.Palette.allCases) { color in
                Button {
                    bank.color = color
                    do {
                        try context.save()
                    }
                    catch {
                        print("Save error:", error)
                    }
                    dismiss()
                } label: {
                    Circle()
                        .fill(color.swiftUIColor)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    Color.primary.opacity(color == bank.color ? 1 : 0),
                                    lineWidth: color == bank.color ? 3 : 0
                                )
                        )
                        .overlay(
                            Group {
                                if color == bank.color { Image(systemName: "checkmark").font(.caption.bold()).foregroundStyle(.primary) }
                            }
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle(bank.name)
    }
}

#Preview {
    NavigationStack {
        ColorView(bank: Bank(name: "BNP Paribas", color: .green, logoAvaibility: .available))
    }
}

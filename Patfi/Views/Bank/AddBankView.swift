import SwiftUI
import SwiftData

struct AddBankView: View {
    
    var bank: Bank? = nil
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var name: String = ""
    @State private var palette: Bank.Palette = .blue
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(palette.swiftUIColor)
                                .frame(width: 32, height: 32)
                            Text(initialLetter())
                                .font(.headline)
                                .foregroundStyle(.white)
                        }
                        TextField("Bank's name", text: $name)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled()
                            .focused($focused)
                    }
                }

                Section("Color") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Bank.Palette.allCases) { p in
                                Button {
                                    palette = p
                                } label: {
                                    Circle()
                                        .fill(p.swiftUIColor)
                                        .frame(width: 36, height: 36)
                                        .overlay(
                                            Circle()
                                                .strokeBorder(
                                                    p == palette ? Color.primary.opacity(0.6) : Color.primary.opacity(0.15),
                                                    lineWidth: p == palette ? 3 : 1
                                                )
                                        )
                                        .overlay(
                                            Group {
                                                if p == palette { Image(systemName: "checkmark").font(.caption.bold()).foregroundStyle(.white) }
                                            }
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle(bank == nil ? "New bank" : "Edit bank")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(bank == nil ? "Create" : "Save") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                if let bank {
                    name = bank.name
                    palette = bank.color
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { focused = true }
            }
        }
    }

    private func initialLetter() -> String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if let first = trimmed.first { return String(first).uppercased() }
        return "?"
    }

    private func save() {
        if let bank {
            bank.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
            bank.color = palette
        } else {
            let bank = Bank(name: name.trimmingCharacters(in: .whitespacesAndNewlines), color: palette)
            context.insert(bank)
        }
        do { try context.save() } catch { print("Save error:", error) }
        dismiss()
    }
}

#Preview {
    AddBankView()
        .modelContainer(for: [Bank.self], inMemory: true)
}

import SwiftUI
import SwiftData

struct EditBankView: View {
    
    var bank: Bank? = nil
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @State private var name: String = ""
    @State private var palette: Bank.Palette = .random
    @State private var logoImage: Image? = nil
    @State private var displayLogo: Bool = false
    @FocusState private var focused: Bool
    @State private var debounceTask: DispatchWorkItem? = nil
    @State private var logoAvailability: Bank.LogoAvailability = .unknown
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 20) {
                        if logoImage != nil, displayLogo {
                            BankLogo(bank: Bank(name: name, color: palette, logoAvaibility: .available))
                        } else {
                            BankLogo(bank: Bank(name: name, color: palette, logoAvaibility: .optedOut))
                        }
                        TextField("Bank", text: $name)
                            #if os(iOS) || os(tvOS) || os(visionOS)
                            .textInputAutocapitalization(.words)
                            #endif
                            .autocorrectionDisabled()
                            .focused($focused)
                    }
                }
                .onChange(of: name) { oldValue, newValue in
                    debounceTask?.cancel()
                    guard oldValue != newValue else { return }
                    let task = DispatchWorkItem {
                        Task {
                            if newValue.count > 2 {
                                let bank = Bank(name: newValue)
                                if let img = await bank.getLogo() {
                                    logoImage = img
                                    if logoAvailability != .optedOut {
                                        displayLogo = true
                                        logoAvailability = .available
                                    }
                                } else {
                                    logoAvailability = .unavailable
                                    displayLogo = false
                                    logoImage = nil
                                }
                            } else {
                                logoImage = nil
                                logoAvailability = .unknown
                                displayLogo = false
                            }
                        }
                    }
                    debounceTask = task
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: task)
                }
                
                // Logo toggle section
                if logoImage != nil {
                    Section {
                        Toggle("Display logo", isOn: $displayLogo)
                            .onChange(of: displayLogo) { oldValue, newValue in
                                if !newValue {
                                    logoAvailability = .optedOut
                                } else {
                                    logoAvailability = .available
                                }
                            }
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
                                                    Color.primary.opacity(p == palette ? 1 : 0),
                                                    lineWidth: p == palette ? 3 : 0
                                                )
                                        )
                                        .overlay(
                                            Group {
                                                if p == palette { Image(systemName: "checkmark").font(.caption.bold()).foregroundStyle(.primary) }
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
            #if os(macOS)
            .padding()
            #endif
            .navigationTitle(bank == nil ? "New bank" : "Edit bank")
            .toolbar {
                #if !os(watchOS)
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel, action: { dismiss() })
                }
                #endif
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm, action: { save() })
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                if let bank { // Update
                    name = bank.name
                    palette = bank.color
                    logoAvailability = bank.logoAvailability
                    displayLogo = !(bank.logoAvailability == .optedOut)
                } else { // Creation
                    logoAvailability = .unknown
                }
                // Load logo image asynchronously
                Task {
                    if let img = await bank?.getLogo() {
                        logoImage = img
                    }
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
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if let bank { // Update
            if bank.name != trimmedName {
                bank.name = trimmedName
            }
            bank.color = palette
            bank.logoAvailability = logoAvailability
        } else { // Creation
            let bank = Bank(name: trimmedName, color: palette, logoAvaibility: logoAvailability)
            context.insert(bank)
        }
        do {
            try context.save()
        }
        catch {
            print("Save error:", error)
        }
        dismiss()
    }
    
}

#Preview {
    EditBankView()
}


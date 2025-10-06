import SwiftUI

struct ModeView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var mode: Mode

    var body: some View {
        NavigationView {
            List {
                ForEach(Mode.allCases) { m in
                    Button {
                        mode = m
                        dismiss()
                    } label: {
                        HStack {
                            Text(m.localized)
                            Spacer()
                            if mode == m {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.primary)
                                    .bold()
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ModeView(mode: .constant(.categories))
}

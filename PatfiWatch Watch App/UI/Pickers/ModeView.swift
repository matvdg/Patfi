import SwiftUI

struct ModeView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Binding var mode: WatchMode

    var body: some View {
        NavigationView {
            List {
                ForEach(WatchMode.allCases) { m in
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
    @Previewable @State var mode: WatchMode = .categories
    ModeView(mode: $mode)
}

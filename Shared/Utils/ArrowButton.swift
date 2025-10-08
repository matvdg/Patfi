import SwiftUI

struct ArrowButton: View {
    
    @Binding var isUp: Bool

    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                isUp.toggle()
            }
        }) {
            Image(systemName: "chevron.up")
                .foregroundColor(.primary)
                .rotationEffect(.degrees(isUp ? 180 : 0))
                .padding(4)
        }
        .buttonStyle(.bordered)
        .controlSize(.mini)
    }
}

#Preview {
    ArrowButton(isUp: .constant(false))
}

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

struct ArrowRightButton: View {
    
    @Binding var isRight: Bool

    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                isRight.toggle()
            }
        }) {
            Image(systemName: "chevron.right")
                .rotationEffect(.degrees(isRight ? 0 : 90))
                .padding(4)
        }
    }
}

struct CollapseButton: View {
    
    @Binding var isCollapsed: Bool

    var body: some View {
        Button(action: {
            isCollapsed.toggle()
        }) {
            Image(systemName: isCollapsed ? "arrow.up.left.and.arrow.down.right" : "arrow.down.right.and.arrow.up.left")
                .foregroundColor(.primary)
                .padding(4)
        }
    }
}

#Preview {
    ArrowButton(isUp: .constant(false))
    ArrowRightButton(isRight: .constant(false))
    CollapseButton(isCollapsed: .constant(false))
}

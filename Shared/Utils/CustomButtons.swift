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

struct ArrowRightButton<Content: View>: View {
    @Binding var isRight: Bool
    let content: () -> Content

    init(isRight: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) {
        self._isRight = isRight
        self.content = content
    }

    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                isRight.toggle()
            }
        }) {
            HStack {
                content()
                Spacer()
                Image(systemName: "chevron.right")
                    .rotationEffect(.degrees(isRight ? 0 : 90))
                    .padding(4)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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

struct PaymentMethodButton: View {
    
    @Binding var sortByPaymentMethod: Bool

    var body: some View {
        Button(action: {
            sortByPaymentMethod.toggle()
        }) {
            Image(systemName: sortByPaymentMethod ? "creditcard.fill" : "creditcard")
                .foregroundColor(.primary)
                .padding(4)
        }
    }
}

struct BankButton: View {
    
    @Binding var sortByBank: Bool

    var body: some View {
        Button(action: {
            sortByBank.toggle()
        }) {
            Image(systemName: sortByBank ? "building.columns.fill" : "building.columns")
                .foregroundColor(.primary)
                .padding(4)
        }
    }
}

#Preview {
    ArrowButton(isUp: .constant(false))
    ArrowRightButton(isRight: .constant(false)) {
        Text("Exemple")
            .padding(.leading, 8)
    }
    CollapseButton(isCollapsed: .constant(false))
    PaymentMethodButton(sortByPaymentMethod: .constant(false))
    BankButton(sortByBank: .constant(false))
}

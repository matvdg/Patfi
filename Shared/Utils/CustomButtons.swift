import SwiftUI

struct CheckButton: View {
    
    var isMentalMathCorrect: Bool
    @Binding var isPressed: Bool

    var body: some View {
        Button {
            if isMentalMathCorrect {
                AppSound.success.play()
            } else {
                AppSound.error.play()
            }
            withAnimation(.easeInOut(duration: 0.3)) {
                isPressed = true
            }
        } label: {
            Label("Check", systemImage: "checkmark.diamond.fill")
                .padding()
        }
        .overlay(
            Text(isMentalMathCorrect ? "True" : "False")
                .textCase(.uppercase)
                .bold()
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    (isMentalMathCorrect ? Color.green : Color.red)
                        .cornerRadius(40)
                )
                .opacity(isPressed ? 1 : 0)
        )
        .modifier(ButtonStyleProminentModifier())
    }
}


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

struct FavButton: View {
    
    @Binding var isFav: Bool

    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                isFav.toggle()
            }
        }) {
            Image(systemName: isFav ? "star.fill" : "star")
                .foregroundColor(isFav ? .yellow : .primary)
                .padding(4)
        }
        .buttonStyle(.bordered)
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

struct ButtonStyleProminentModifier: ViewModifier {
    
    var isProminentForAppleWatchToo: Bool = true
    
    func body(content: Content) -> some View {
#if os(visionOS)
        content.buttonStyle(.borderedProminent)
#elseif os(watchOS)
        if #available(watchOS 26.0, *) {
            if isProminentForAppleWatchToo {
                content.buttonStyle(.glassProminent)
            } else {
                content.buttonStyle(.plain)
            }
        } else {
            if isProminentForAppleWatchToo {
                content.buttonStyle(.borderedProminent)
            } else {
                content.buttonStyle(.plain) // false for TwelveDataPicker must be plain on watchOS
            }
        }
#elseif os(macOS)
        content.buttonStyle(.bordered)
#else
        if #available(iOS 26.0, *) {
            content.buttonStyle(.glassProminent)
        } else {
            content.buttonStyle(.borderedProminent)
        }
#endif
    }
}

struct ButtonStyleModifier: ViewModifier {
    
    func body(content: Content) -> some View {
#if os(visionOS)
        content.buttonStyle(.borderedProminent)
#elseif os(watchOS)
        if #available(watchOS 26.0, *) {
            content.buttonStyle(.glass)
        } else {
            content.buttonStyle(.bordered)
        }
#elseif os(macOS)
        content.buttonStyle(.bordered)
#else
        if #available(iOS 26.0, *) {
            content.buttonStyle(.glass)
        } else {
            content.buttonStyle(.bordered)
        }
#endif
    }
}



#Preview {
    @Previewable @State var isOn = false
    ScrollView {
        ArrowButton(isUp: $isOn)
        ArrowRightButton(isRight: $isOn) {
            Text("Exemple")
                .padding(.leading, 8)
        }
        CollapseButton(isCollapsed: $isOn)
        PaymentMethodButton(sortByPaymentMethod: $isOn)
        BankButton(sortByBank: $isOn)
        FavButton(isFav: $isOn)
        CheckButton(isMentalMathCorrect: false, isPressed: $isOn)
        CheckButton(isMentalMathCorrect: true, isPressed: $isOn)
    }
}

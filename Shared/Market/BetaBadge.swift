import SwiftUI

struct BetaBadge: View {
    var body: some View {
        Text("🧪 ßeta v3")
            .bold()
            .font(.title3)
            .foregroundStyle(Color(.green))
            .transition(.scale.combined(with: .opacity))
            .padding()
            .background(Color.green.opacity(0.2))
            .clipShape(Capsule())
            .padding()
    }
}

#Preview {
    BetaBadge()
}

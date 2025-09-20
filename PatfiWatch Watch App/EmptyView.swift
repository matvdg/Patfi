import SwiftUI

struct EmptyView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            ContentUnavailableView("No accounts", systemImage: "creditcard")
            Text("Add Accounts")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding()
            
        }
    }
}

#Preview {
    EmptyView()
}

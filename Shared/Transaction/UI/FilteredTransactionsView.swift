import SwiftUI
import SwiftData

struct FilteredTransactionsView: View {
    
    @State private var selectedMonth: Date = .now
    @State private var hideInternalTransfers: Bool = false
    
    var body: some View {
        VStack {
            MonthPicker(selectedMonth: $selectedMonth)
            Toggle("hideInternalTransfers", isOn: $hideInternalTransfers)
                    .padding(.horizontal)
            TransactionsView(month: selectedMonth, hideInternalTransfers: hideInternalTransfers)
        }
    }
}

#Preview {
    NavigationStack {
        FilteredTransactionsView()
            .modelContainer(ModelContainer.shared)
    }
}

import SwiftUI
import SwiftData

struct FilteredTransactionsView: View {
    
    @State private var selectedMonth: Date = .now
    @State private var hideInternalTransfers: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) {
                        selectedMonth = newDate
                    }
                } label: {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(selectedMonth, format: Date.FormatStyle().month(.wide).year())
                    .font(.headline)
                Spacer()
                Button {
                    if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) {
                        selectedMonth = newDate
                    }
                } label: {
                    Image(systemName: "chevron.right")
                }
                .disabled(Calendar.current.isDate(selectedMonth, equalTo: Date(), toGranularity: .month))
                Spacer()
            }
            .buttonStyle(.glassProminent)
            .padding()
            Toggle("HideInternalTransfers", isOn: $hideInternalTransfers)
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

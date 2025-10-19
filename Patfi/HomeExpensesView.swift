import SwiftUI
import SwiftData
import Playgrounds

struct HomeExpensesView: View {
    
    @State private var selectedMonth: Date = .now
    
    var body: some View {
        
        VStack(alignment: .center) {
            MonthPicker(selectedMonth: $selectedMonth)
            ExpensesView(selectedMonth: selectedMonth)
#if os(macOS)
                .listStyle(.plain)
                .padding()
#else
                .listStyle(.insetGrouped)
#endif
        }
    }
}

#Preview {
    HomeExpensesView()
        .modelContainer(ModelContainer.shared)
}

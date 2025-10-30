import SwiftUI
import SwiftData

struct HomeMonitoringView: View {
    
    @State private var selectedDate: Date = .now
    @State private var selectedPeriod: Period = .month
    
    var body: some View {
        VStack {
            TwelvePeriodPicker(selectedDate: $selectedDate, selectedPeriod: $selectedPeriod)
            MonitoringView(for: selectedPeriod, containing: selectedDate)
                .onAppear {
                    selectedDate = selectedDate.normalizedDate(selectedPeriod: selectedPeriod)
                }
        }
        
    }
}

#Preview {
    NavigationStack { HomeMonitoringView() }
        .modelContainer(ModelContainer.shared)
}

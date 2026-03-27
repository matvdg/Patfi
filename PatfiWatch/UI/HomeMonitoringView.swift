import SwiftUI
import SwiftData

struct HomeMonitoringView: View {
    
    @AppStorage(Keys.selectedDate) private var selectedDate: Date = Date()
    @AppStorage(Keys.selectedPeriod) private var selectedPeriod: Period = .month
    
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

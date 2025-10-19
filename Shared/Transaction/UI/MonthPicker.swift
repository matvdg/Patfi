import SwiftUI

struct MonthPicker: View {
    
    @Binding var selectedMonth: Date
    
    var body: some View {
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
#if os(visionOS)
.buttonStyle(.borderedProminent)
#else
.buttonStyle(.glassProminent)
#endif
        .padding()
    }
}

#Preview {
    MonthPicker(selectedMonth: .constant(Date()))
}

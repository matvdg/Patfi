import SwiftUI

struct PeriodPicker: View {
    
    @Binding var selectedDate: Date
    @Binding var selectedPeriod: Period
    
    var body: some View {
        HStack {
            Spacer()
            Button {
                if let newDate = Calendar.current.date(byAdding: selectedPeriod.component, value: -1, to: selectedDate) {
                    selectedDate = newDate
                }
            } label: {
                Image(systemName: "chevron.left")
            }
            Spacer()
#if os(watchOS)
                Picker(selection: $selectedPeriod) {
                    ForEach(Period.allCases) { selectedPeriod in
                        let label = String(localized: "GroupBy") + String(localized: selectedPeriod.localized).lowercased()
                        Text(label)
                            .tag(selectedPeriod)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                } label: {
                    Text(displayText(for: selectedDate, selectedPeriod: selectedPeriod))
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .pickerStyle(.navigationLink)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
#else
            Menu {
                ForEach(Period.allCases) { selectedPeriod in
                    Button(selectedPeriod == self.selectedPeriod ? "✓ \(selectedPeriod.localized)" : selectedPeriod.localized) { self.selectedPeriod = selectedPeriod }
                    .tag(selectedPeriod)
                }
            } label: {
                Text(displayText(for: selectedDate, selectedPeriod: selectedPeriod))
                    .font(.headline)
            }
            .buttonStyle(.plain)
#endif
            Spacer()
            Button {
                if let newDate = Calendar.current.date(byAdding: selectedPeriod.component, value: 1, to: selectedDate) {
                    selectedDate = newDate
                }
            } label: {
                Image(systemName: "chevron.right")
            }
            .disabled(Calendar.current.isDate(selectedDate, equalTo: Date(), toGranularity: selectedPeriod.component))
            Spacer()
        }
        .modifier(ButtonStyleModifier(isProminent: false))
        .padding()
    }
    
    private func displayText(for date: Date, selectedPeriod: Period) -> String {
        let calendar = Calendar.current
        switch selectedPeriod {
        case .day:
            return date.formatted(Date.FormatStyle().day().month(.wide).year()).capitalized
        case .week:
            let weekOfYear = calendar.component(.weekOfYear, from: date)
            let year = calendar.component(.yearForWeekOfYear, from: date)
            return "\(String(localized: "Week")) \(weekOfYear), \(year)".capitalized
        case .month:
            return date.formatted(Date.FormatStyle().month(.wide).year()).capitalized
        case .year:
            return date.formatted(Date.FormatStyle().year()).capitalized
        }
    }
}

#Preview {
    @Previewable @State var date: Date = Date()
    @Previewable @State var selectedPeriod: Period = .month
    PeriodPicker(selectedDate: $date, selectedPeriod: $selectedPeriod)
}

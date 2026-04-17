import SwiftUI

struct TwelvePeriodPicker: View {
    
    @Binding var selectedDate: Date
    @Binding var selectedPeriod: Period

    init(selectedDate: Binding<Date>, selectedPeriod: Binding<Period>) {
        self._selectedDate = selectedDate
        self._selectedPeriod = selectedPeriod
    }
    
    private let calendar = Calendar.current
    
    var body: some View {
        HStack {
            Spacer()
            Button {
                if let newDate = calendar.date(byAdding: selectedPeriod.component, value: -1, to: selectedDate) {
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
                    .minimumScaleFactor(0.5)
            }
            .pickerStyle(.navigationLink)
            .lineLimit(1)
#else
            Menu {
                ForEach(Period.allCases) { selectedPeriod in
                    Button(selectedPeriod == self.selectedPeriod ? "✓ \(selectedPeriod.localized)" : "\(selectedPeriod.localized)") { self.selectedPeriod = selectedPeriod }
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
                if let newDate = calendar.date(byAdding: selectedPeriod.component, value: 1, to: selectedDate) {
                    selectedDate = clampedToToday(newDate, for: selectedPeriod)
                }
            } label: {
                Image(systemName: "chevron.right")
            }
            .disabled(calendar.isDate(selectedDate, equalTo: Date(), toGranularity: selectedPeriod.component))
            if !calendar.isDate(selectedDate, equalTo: Date(), toGranularity: selectedPeriod.component) {
                Button {
                    selectedDate = Date()
                } label: {
                    Image(systemName: "chevron.forward.to.line")
                }
            }
            Spacer()
        }
        .modifier(ButtonStyleProminentModifier(isProminentForAppleWatchToo: false))
        .padding()
        .onChange(of: selectedPeriod) {
            selectedDate = clampedToToday(selectedDate, for: selectedPeriod)
        }
    }
    
    private func clampedToToday(_ date: Date, for period: Period) -> Date {
        let today = Date()
        if calendar.compare(date, to: today, toGranularity: period.component) == .orderedDescending {
            return today
        }
        return date
    }
    
    private func displayText(for date: Date, selectedPeriod: Period) -> String {
        let isNow = selectedDate.isNow(for: selectedPeriod)
        let now = String(localized: "Now")
        let calendar = Calendar.current
        switch selectedPeriod {
        case .day:
            let startDate = calendar.date(byAdding: .day, value: -11, to: selectedDate)!
            let startStr = startDate.formatted(Date.FormatStyle().day().month(.abbreviated))
            let endStr = isNow ? now : selectedDate.formatted(Date.FormatStyle().day().month(.abbreviated).year())
            return "\(startStr) – \(endStr)".capitalized
        case .week:
            let startDate = calendar.date(byAdding: .weekOfYear, value: -11, to: selectedDate)!
            let startWeek = calendar.component(.weekOfYear, from: startDate)
            let startYear = calendar.component(.yearForWeekOfYear, from: startDate)
            let endWeek = calendar.component(.weekOfYear, from: selectedDate)
            let endYear = calendar.component(.yearForWeekOfYear, from: selectedDate)
            let startWeekStr = String(localized: "W\(startWeek)")
            let endWeekStr = isNow ? now : String(localized: "W\(endWeek)") + " \(endYear)"
            if startYear == endYear {
                return "\(startWeekStr) – \(endWeekStr)"
            } else {
                return "\(startWeekStr) \(startYear) – \(endWeekStr)"
            }
        case .month:
            let startDate = calendar.date(byAdding: .month, value: -11, to: selectedDate)!
            let startStr = startDate.formatted(.dateTime.month(.abbreviated).year())
            let endStr = isNow ? now : selectedDate.formatted(.dateTime.month(.abbreviated).year())
            return "\(startStr) – \(endStr)".capitalized
        case .year:
            let startDate = calendar.date(byAdding: .year, value: -4, to: selectedDate)!
            let startYear = calendar.component(.year, from: startDate)
            let endYear = isNow ? now : "\(calendar.component(.year, from: selectedDate))"
            return "\(startYear) – \(endYear)"
        }
    }
}

#Preview {
    @Previewable @State var date: Date = Date()
    @Previewable @State var selectedPeriod: Period = .month
    TwelvePeriodPicker(selectedDate: $date, selectedPeriod: $selectedPeriod)
}

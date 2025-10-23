import SwiftUI

struct TwelvePeriodPicker: View {
    
    @Binding var selectedDate: Date
    @Binding var period: Period

    init(selectedDate: Binding<Date>, period: Binding<Period>) {
        self._selectedDate = selectedDate
        self._period = period
        self._selectedDate.wrappedValue = normalizedDate(for: selectedDate.wrappedValue, period: period.wrappedValue)
    }
    
    func normalizedDate(for date: Date, period: Period) -> Date {
        let cal = Calendar.current
        switch period {
        case .days:
            return cal.dateInterval(of: .day, for: date)!.end
        case .weeks:
            return cal.dateInterval(of: .weekOfYear, for: date)!.end
        case .months:
            return cal.dateInterval(of: .month, for: date)!.end
        case .years:
            return cal.dateInterval(of: .year, for: date)!.end
        }
    }
    
    var body: some View {
        HStack {
            Spacer()
            Button {
                let cal = Calendar.current
                // Step back 1 second so a boundary date (e.g., month end -> next month start) is treated as part of the intended period
                let reference = cal.date(byAdding: .second, value: -1, to: selectedDate) ?? selectedDate
                let start = cal.dateInterval(of: component(for: period), for: reference)!.start
                if let newDate = cal.date(byAdding: component(for: period), value: -1, to: start) {
                    selectedDate = normalizedDate(for: newDate, period: period)
                }
            } label: {
                Image(systemName: "chevron.left")
            }
            Spacer()
#if os(watchOS)
            Text(displayText(for: selectedDate, period: period))
                .font(.headline)
#else
            Menu {
                ForEach(Period.allCases) { period in
                    Button(period == self.period ? "✓ \(period.localized)" : period.localized) { self.period = period }
                    .tag(period)
                }
            } label: {
                Text(displayText(for: selectedDate, period: period))
                    .font(.headline)
            }
            .buttonStyle(.plain)
#endif
            Spacer()
            Button {
                let cal = Calendar.current
                // Same boundary-safe reference
                let reference = cal.date(byAdding: .second, value: -1, to: selectedDate) ?? selectedDate
                let start = cal.dateInterval(of: component(for: period), for: reference)!.start
                if let newDate = cal.date(byAdding: component(for: period), value: 1, to: start) {
                    selectedDate = normalizedDate(for: newDate, period: period)
                }
            } label: {
                Image(systemName: "chevron.right")
            }
            .disabled(Calendar.current.isDate(selectedDate, equalTo: Date(), toGranularity: component(for: period)))
            Spacer()
        }
#if os(visionOS)
.buttonStyle(.borderedProminent)
#elseif os(watchOS)
.buttonStyle(.plain)
#else
.buttonStyle(.glassProminent)
#endif
        .padding()
    }
    
    private func component(for period: Period) -> Calendar.Component {
        switch period {
        case .days:
            return .day
        case .weeks:
            return .weekOfYear
        case .months:
            return .month
        case .years:
            return .year
        }
    }
    
    private func displayText(for date: Date, period: Period) -> String {
        let calendar = Calendar.current
        switch period {
        case .days:
            guard let start = calendar.date(byAdding: .day, value: -10, to: date) else { return "" }
            let startStr = start.formatted(Date.FormatStyle().day().month(.abbreviated))
            let endStr = date.formatted(Date.FormatStyle().day().month(.abbreviated).year())
            return "\(startStr) – \(endStr)".capitalized
        case .weeks:
            guard let start = calendar.date(byAdding: .weekOfYear, value: -10, to: date) else { return "" }
            let startWeek = calendar.component(.weekOfYear, from: start)
            let startYear = calendar.component(.yearForWeekOfYear, from: start)
            let endWeek = calendar.component(.weekOfYear, from: date)
            let endYear = calendar.component(.yearForWeekOfYear, from: date)

            let startWeekStr = String(localized: "w\(startWeek)")
            let endWeekStr = String(localized: "w\(endWeek)")

            if startYear == endYear {
                return "\(startWeekStr) – \(endWeekStr) \(endYear)"
            } else {
                return "\(startWeekStr) \(startYear) – \(endWeekStr) \(endYear)"
            }
        case .months:
            guard let start = calendar.date(byAdding: .month, value: -10, to: date) else { return "" }
            let startStr = start.formatted(.dateTime.month(.abbreviated).year())
            let endStr = date.formatted(.dateTime.month(.abbreviated).year())
            return "\(startStr) – \(endStr)".capitalized
        case .years:
            guard let start = calendar.date(byAdding: .year, value: -3, to: date) else { return "" }
            let startYear = calendar.component(.year, from: start)
            let endYear = calendar.component(.year, from: date)
            return "\(startYear) – \(endYear)"
        }
    }
}

#Preview {
    @Previewable @State var date: Date = Date()
    @Previewable @State var period: Period = .months
    TwelvePeriodPicker(selectedDate: $date, period: $period)
}

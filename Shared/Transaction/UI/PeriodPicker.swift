import SwiftUI

struct PeriodPicker: View {
    
    @Binding var selectedDate: Date
    @Binding var period: Period
    
    var body: some View {
        HStack {
            Spacer()
            Button {
                if let newDate = Calendar.current.date(byAdding: component(for: period), value: -1, to: selectedDate) {
                    selectedDate = newDate
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
                if let newDate = Calendar.current.date(byAdding: component(for: period), value: 1, to: selectedDate) {
                    selectedDate = newDate
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
            return date.formatted(Date.FormatStyle().day().month(.wide).year()).capitalized
        case .weeks:
            let weekOfYear = calendar.component(.weekOfYear, from: date)
            let year = calendar.component(.yearForWeekOfYear, from: date)
            return "\(String(localized: "week")) \(weekOfYear), \(year)".capitalized
        case .months:
            return date.formatted(Date.FormatStyle().month(.wide).year()).capitalized
        case .years:
            return date.formatted(Date.FormatStyle().year()).capitalized
        }
    }
}

#Preview {
    PeriodPicker(selectedDate: .constant(Date()), period: .constant(.months))
}

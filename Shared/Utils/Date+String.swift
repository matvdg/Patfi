import Foundation

extension Date {
    
    var toDateStyleMediumString: String {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df.string(from: self)
    }
    
    var toDateStyleShortString: String {
        let df = DateFormatter()
        df.dateStyle = .short
        return df.string(from: self)
    }
    
    func normalizedDate(selectedPeriod: Period) -> Date {
        let cal = Calendar.current
        var date: Date
        switch selectedPeriod {
        case .day:
            date = cal.dateInterval(of: .day, for: self)!.end
        case .week:
            date = cal.dateInterval(of: .weekOfYear, for: self)!.end
        case .month:
            date = cal.dateInterval(of: .month, for: self)!.end
        case .year:
            date = cal.dateInterval(of: .year, for: self)!.end
        }
        return date.addingTimeInterval(-1)
    }
    
    func isNow(for selectedPeriod: Period) -> Bool {
        self.normalizedDate(selectedPeriod: selectedPeriod) >= Date().normalizedDate(selectedPeriod: selectedPeriod)
    }
    
    func getComponent(for selectedPeriod: Period) -> Int {
        Calendar.current.component(selectedPeriod.component, from: self)
    }
}

import Foundation

extension Date {
    var toString: String {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df.string(from: self)
    }
}

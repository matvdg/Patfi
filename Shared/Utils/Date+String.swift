import Foundation

extension Date {
    
    var toString: String {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df.string(from: self)
    }
    
    var toShortString: String {
        let df = DateFormatter()
        df.dateStyle = .short
        return df.string(from: self)
    }
}

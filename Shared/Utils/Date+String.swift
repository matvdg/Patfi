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
}

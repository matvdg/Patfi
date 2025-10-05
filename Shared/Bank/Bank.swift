import Foundation
import SwiftData
import SwiftUI

@Model
final class Bank: Hashable {
    
    var name: String = ""
    var normalizedName: String {
        name
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: "’", with: "")
            .components(separatedBy: .whitespaces)
            .joined()
    }
    
    var color: Palette = Palette.blue
    
    enum LogoAvailability: String, Codable, CaseIterable, Identifiable {
        var id: String { rawValue }
        
        /// not searched for it yet
        case unknown
        
        /// exists in cache or remotely
        case available
        
        /// does not exist in cache or in API
        case unavailable
        
        /// available but user opted out
        case optedOut
    }
    
    var logoAvailability = LogoAvailability.unknown
    
    @Relationship(deleteRule: .nullify)
    var accounts: [Account]? = nil
    
    init(name: String = "", color: Palette = .random, logoAvaibility: LogoAvailability = .unknown) {
        self.name = name
        self.color = color
        self.logoAvailability = logoAvaibility
    }
    
    enum Palette: String, Codable, CaseIterable, Identifiable {
        case blue
        case green
        case teal
        case cyan
        case mint
        case purple
        case pink
        case orange
        case yellow
        case red
        case brown
        case gray
        case black
        
        var id: String { rawValue }
        
        static var random: Palette {
            allCases.randomElement() ?? .blue
        }
        
        var swiftUIColor: Color {
            switch self {
            case .blue:   return .blue
            case .green:  return .green
            case .teal:   return .teal
            case .cyan:   return .cyan
            case .mint:   return .mint
            case .purple: return .purple
            case .pink:   return .pink
            case .orange: return .orange
            case .yellow: return .yellow
            case .red:    return .red
            case .brown:  return .brown
            case .gray:   return .gray
            case .black:  return .black
            }
        }
    }
    
    var swiftUIColor: Color { color.swiftUIColor }
    
    var initialLetter: String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let result = trimmed.first.map { String($0).uppercased() } ?? "?"
        return result.isEmpty ? "?" : result
    }
    
    static var sfSymbol: Image {
        let locale = Locale.current.currency?.identifier ?? "USD"
        switch locale {
        case "EUR" : return Image(systemName: "eurosign.bank.building")
        case "GPB" : return Image(systemName: "sterlingsign.bank.building")
        default : return Image(systemName: "dollarsign.bank.building")
        }
    }
}

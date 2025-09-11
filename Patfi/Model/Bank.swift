import Foundation
import SwiftData
import SwiftUI

@Model
final class Bank {
    var name: String = ""
    var color: Palette = Palette.blue
    
    @Relationship(deleteRule: .nullify)
    var accounts: [Account]? = nil

    init(name: String = "", color: Palette = .blue) {
        self.name = name
        self.color = color
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

        var id: String { rawValue }

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
            }
        }
    }

    var swiftUIColor: Color { color.swiftUIColor }
}

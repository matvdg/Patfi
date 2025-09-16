import Foundation
import SwiftData
import SwiftUI

@Model
final class Bank {
    var name: String = ""
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
        return trimmed.first.map { String($0).uppercased() } ?? " "
    }
}

// MARK: - Logo fetching
extension Bank {
    
    /// Attempts to retrieve the bank's logo from local cache or remote API
    /// - Returns: A SwiftUI Image if found, otherwise nil
    func getLogo() async -> Image? {
        if logoAvailability == .unavailable { return nil }
        if let logo = await Bank.getLogo(name: name) {
            if logoAvailability != .optedOut {
                logoAvailability = .available
            }
            return logo
        } else {
            logoAvailability = .unavailable
            return nil
        }
    }
        
    /// Attempts to retrieve the bank's logo from local cache or remote API
    /// - Returns: A SwiftUI Image if found, otherwise nil
    static func getLogo(name: String) async -> Image? {
        
#if os(iOS) || os(tvOS) || os(visionOS)
        
        // Normalize the bank name: remove accents/diacritics, lowercase, remove apostrophes, and remove spaces
        let normalizedName = name
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: "’", with: "")
            .components(separatedBy: .whitespaces)
            .joined()
        
        // Local file path in cache directory
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        guard let cacheURL = urls.first else { return nil }
        let logoFileURL = cacheURL.appendingPathComponent("\(normalizedName).png")
        
        // 0. Check if the logo exists in the app's asset catalog
        if let uiImage = UIImage(named: normalizedName) {
            return Image(uiImage: uiImage)
        }

        // 1. Check if the logo already exists locally
        if fileManager.fileExists(atPath: logoFileURL.path),
           let data = try? Data(contentsOf: logoFileURL),
           let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        }
        
        // 2. Try API
        let urlStringFr = normalizedName.contains(".fr") ? "https://logo.bankconv.com/\(normalizedName)" : "https://logo.bankconv.com/\(normalizedName).fr"
        let urlStringCom = normalizedName.contains(".com") ? "https://logo.bankconv.com/\(normalizedName)" : "https://logo.bankconv.com/\(normalizedName).com"
        
        if let urlCom = URL(string: urlStringCom), let (data, response) = try? await URLSession.shared.data(from: urlCom), let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let uiImage = UIImage(data: data) {
            print("ℹ️ Saving a logo for \(urlStringCom) at \(logoFileURL)")
            try? data.write(to: logoFileURL)
            return Image(uiImage: uiImage)
        } else if let urlFr = URL(string: urlStringFr), let (data, response) = try? await URLSession.shared.data(from: urlFr), let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let uiImage = UIImage(data: data) {
            print("ℹ️ Saving a logo for \(urlStringFr) at \(logoFileURL)")
            try? data.write(to: logoFileURL)
            return Image(uiImage: uiImage)
        } else {
            return nil
        }
        #else
        return nil
        #endif
    }
}

import Foundation
import SwiftUI

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
        
        // 0. Check if the logo exists in the app's asset catalog
        if let uiImage = UIImage(named: normalizedName) {
            return Image(uiImage: uiImage)
        }
        
        // Local file path in cache directory
        let fileManager = FileManager.default
        let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.fr.matvdg.patfi")!
        let cacheURL = groupURL.appendingPathComponent("Caches", isDirectory: true)
        try? fileManager.createDirectory(at: cacheURL, withIntermediateDirectories: true)
        let logoFileURL = cacheURL.appendingPathComponent("\(normalizedName).png")

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

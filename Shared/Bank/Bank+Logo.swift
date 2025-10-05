import Foundation
import SwiftUI

// MARK: - Logo fetching
extension Bank {
    
    /// Attempts to retrieve the bank's logo from local cache or remote API
    /// - Returns: A SwiftUI Image if found, otherwise nil
    @MainActor
    func getLogo() async -> Image? {
        if logoAvailability == .unavailable || logoAvailability == .optedOut {
            return nil
        }
        if let logo = await fetchLogo() {
            logoAvailability = .available
            return logo
        } else {
            return nil
        }
    }
    
    
    /// Attempts to retrieve the bank's logo from local cache
    /// - Returns: A SwiftUI Image if found, otherwise nil
    @MainActor
    func getLogoFromCache() -> Image? {
        
#if os(iOS) || os(tvOS) || os(visionOS) || os(watchOS) || os(macOS)
        
        // 1. Check if the logo exists in the app's asset catalog
        if let platformImage = PlatformImage(named: normalizedName) {
            if let imageData = platformImage.asData {
                if let image = Image(platformImageData: imageData) {
                    return image
                }
            }
            return nil
        }
        
        // Local file path in cache directory
        let fileManager = FileManager.default
        let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: AppIDs.appGroupID)!
        let cacheURL = groupURL.appendingPathComponent("Caches", isDirectory: true)
        try? fileManager.createDirectory(at: cacheURL, withIntermediateDirectories: true)
        let logoFileURL = cacheURL.appendingPathComponent("\(normalizedName).png")
        
        // 2. Check if the logo already exists locally
        if fileManager.fileExists(atPath: logoFileURL.path),
           let data = try? Data(contentsOf: logoFileURL),
           let image = Image(platformImageData: data) {
            return image
        } else {
            return nil
        }
#else
        return nil
#endif
    }
    
    /// Attempts to retrieve the bank's logo from local cache or remote API
    /// - Returns: A SwiftUI Image if found, otherwise nil
    @MainActor
    private func fetchLogo() async -> Image? {
        let fileManager = FileManager.default
        let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: AppIDs.appGroupID)!
        let cacheURL = groupURL.appendingPathComponent("Caches", isDirectory: true)
        try? fileManager.createDirectory(at: cacheURL, withIntermediateDirectories: true)
        let logoFileURL = cacheURL.appendingPathComponent("\(normalizedName).png")
        
        if let logo = getLogoFromCache() {
            return logo
        }
        
        // Banks logo API
        let urlStringFr = normalizedName.contains(".fr") ? "https://logo.bankconv.com/\(normalizedName)" : "https://logo.bankconv.com/\(normalizedName).fr"
        let urlStringCom = normalizedName.contains(".com") ? "https://logo.bankconv.com/\(normalizedName)" : "https://logo.bankconv.com/\(normalizedName).com"
        if let urlCom = URL(string: urlStringCom),
                  let (data, response) = try? await URLSession.shared.data(from: urlCom),
                  let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let image = Image(platformImageData: data) {
            print("ℹ️ Saving a logo for \(urlStringCom) at \(logoFileURL)")
            try? data.write(to: logoFileURL)
            return image
        } else if let urlFr = URL(string: urlStringFr),
                  let (data, response) = try? await URLSession.shared.data(from: urlFr),
                  let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let image = Image(platformImageData: data) {
            print("ℹ️ Saving a logo for \(urlStringFr) at \(logoFileURL)")
            try? data.write(to: logoFileURL)
            return image
        } else {
            return nil
        }
    }
  
}


#if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
import UIKit
typealias PlatformImage = UIImage

extension PlatformImage {
    var asData: Data? {
        return self.pngData()
    }
}
#elseif os(macOS)
import AppKit
typealias PlatformImage = NSImage

extension PlatformImage {
    var asData: Data? {
        guard let tiffData = self.tiffRepresentation else { return nil }
        guard let bitmapImage = NSBitmapImageRep(data: tiffData) else { return nil }
        return bitmapImage.representation(using: .png, properties: [:])
    }
}
#endif

extension Image {
    @MainActor init?(platformImageData data: Data) {
        guard let img = PlatformImage(data: data) else { return nil }
#if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
        self = Image(uiImage: img)
#elseif os(macOS)
        self = Image(nsImage: img)
#endif
    }
}

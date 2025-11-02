import Foundation

#if os(iOS)
import UIKit
import AudioToolbox
#elseif os(watchOS)
import WatchKit
import UIKit
#elseif os(macOS)
import AppKit
#endif

enum AppSound {
    case success
    case error
    case warning

    @MainActor
    func play() {
#if os(macOS)
        let soundName: NSSound.Name
        switch self {
        case .success:
            soundName = NSSound.Name("Glass")
        case .error:
            soundName = NSSound.Name("Basso")
        case .warning:
            soundName = NSSound.Name("Submarine")
        }
        NSSound(named: soundName)?.play()
#elseif os(iOS)
        let feedbackType: UINotificationFeedbackGenerator.FeedbackType
        switch self {
        case .success:
            feedbackType = .success
        case .error:
            feedbackType = .error
        case .warning:
            feedbackType = .warning
        }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(feedbackType)

        let systemSoundID: SystemSoundID
        switch self {
        case .success:
            systemSoundID = 1013
        case .error:
            systemSoundID = 1053
        case .warning:
            systemSoundID = 1001
        }
        AudioServicesPlaySystemSound(systemSoundID)
#elseif os(watchOS)
        let hapticType: WKHapticType
        switch self {
        case .success:
            hapticType = .success
        case .error:
            hapticType = .failure
        case .warning:
            hapticType = .notification
        }
        WKInterfaceDevice.current().play(hapticType)
#endif
    }
}

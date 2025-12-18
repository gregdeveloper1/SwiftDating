import Foundation

/// App-wide constants and configuration
enum Constants {
    // MARK: - App Info

    static let appName = "NativeDating"
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

    // MARK: - Profile Limits

    static let maxPhotos = 6
    static let minPhotos = 2
    static let maxBioLength = 500
    static let maxPromptAnswerLength = 300
    static let maxInterests = 10

    // MARK: - Discovery Settings

    static let defaultSearchRadius: Int = 50 // km
    static let maxSearchRadius: Int = 500 // km
    static let minAge: Int = 18
    static let maxAge: Int = 100
    static let defaultAgeRange: ClosedRange<Int> = 18...50
    static let cardsToPreload: Int = 10

    // MARK: - Chat Settings

    static let messagesPerPage: Int = 50
    static let maxMessageLength: Int = 2000
    static let typingIndicatorTimeout: TimeInterval = 3.0

    // MARK: - Feed Settings

    static let postsPerPage: Int = 20
    static let maxPostLength: Int = 500
    static let maxCommentLength: Int = 500

    // MARK: - Image Settings

    static let maxImageSize: Int = 5 * 1024 * 1024 // 5MB
    static let thumbnailSize: CGFloat = 200
    static let profilePhotoSize: CGFloat = 800
    static let compressionQuality: CGFloat = 0.8

    // MARK: - Animation Durations

    static let swipeAnimationDuration: TimeInterval = 0.3
    static let matchAnimationDuration: TimeInterval = 0.5
    static let transitionDuration: TimeInterval = 0.25

    // MARK: - Swipe Thresholds

    static let swipeThreshold: CGFloat = 100
    static let superLikeThreshold: CGFloat = -100 // Swipe up
    static let maxRotation: Double = 12.0
}

// MARK: - User Defaults Keys

enum UserDefaultsKey {
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
    static let lastKnownLocation = "lastKnownLocation"
    static let searchRadius = "searchRadius"
    static let ageRangeMin = "ageRangeMin"
    static let ageRangeMax = "ageRangeMax"
    static let genderPreference = "genderPreference"
    static let showDistance = "showDistance"
    static let notificationsEnabled = "notificationsEnabled"
}

// MARK: - Notification Names

extension Notification.Name {
    static let userDidLogin = Notification.Name("userDidLogin")
    static let userDidLogout = Notification.Name("userDidLogout")
    static let newMatchReceived = Notification.Name("newMatchReceived")
    static let newMessageReceived = Notification.Name("newMessageReceived")
    static let profileUpdated = Notification.Name("profileUpdated")
}

import SwiftUI

/// Centralized haptic feedback manager
enum Haptics {
    // MARK: - Impact Feedback

    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    static func lightImpact() {
        impact(.light)
    }

    static func mediumImpact() {
        impact(.medium)
    }

    static func heavyImpact() {
        impact(.heavy)
    }

    static func softImpact() {
        impact(.soft)
    }

    static func rigidImpact() {
        impact(.rigid)
    }

    // MARK: - Notification Feedback

    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }

    static func success() {
        notification(.success)
    }

    static func warning() {
        notification(.warning)
    }

    static func error() {
        notification(.error)
    }

    // MARK: - Selection Feedback

    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    // MARK: - Custom Patterns

    /// Double tap feedback
    static func doubleTap() {
        lightImpact()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            lightImpact()
        }
    }

    /// Swipe like feedback
    static func swipeLike() {
        success()
    }

    /// Swipe nope feedback
    static func swipeNope() {
        lightImpact()
    }

    /// Super like feedback
    static func superLike() {
        heavyImpact()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            success()
        }
    }

    /// New match feedback
    static func newMatch() {
        heavyImpact()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            mediumImpact()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            success()
        }
    }

    /// Message sent feedback
    static func messageSent() {
        softImpact()
    }

    /// Button tap feedback
    static func buttonTap() {
        lightImpact()
    }

    /// Tab change feedback
    static func tabChange() {
        selection()
    }
}

// MARK: - View Extension

extension View {
    /// Adds haptic feedback on tap
    func hapticOnTap(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded { _ in
                Haptics.impact(style)
            }
        )
    }
}

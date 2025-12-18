import SwiftUI

/// Design system for NativeDating - Black & White Glass Morphism
enum Theme {
    // MARK: - Colors (Monochrome Only)

    static let background = Color.black
    static let surface = Color.white.opacity(0.05)
    static let surfaceHover = Color.white.opacity(0.1)
    static let surfaceActive = Color.white.opacity(0.15)

    static let border = Color.white.opacity(0.2)
    static let borderLight = Color.white.opacity(0.1)
    static let borderHighlight = Color.white.opacity(0.4)

    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let textTertiary = Color.white.opacity(0.5)
    static let textDisabled = Color.white.opacity(0.3)

    static let accent = Color.white
    static let accentMuted = Color.white.opacity(0.8)

    // MARK: - Typography

    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let headline = Font.system(size: 17, weight: .semibold, design: .default)
    static let body = Font.system(size: 17, weight: .regular, design: .default)
    static let callout = Font.system(size: 16, weight: .regular, design: .default)
    static let subheadline = Font.system(size: 15, weight: .regular, design: .default)
    static let footnote = Font.system(size: 13, weight: .regular, design: .default)
    static let caption = Font.system(size: 12, weight: .regular, design: .default)
    static let caption2 = Font.system(size: 11, weight: .regular, design: .default)

    // MARK: - Spacing

    static let spacingXXS: CGFloat = 2
    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 16
    static let spacingL: CGFloat = 24
    static let spacingXL: CGFloat = 32
    static let spacingXXL: CGFloat = 48

    // MARK: - Corner Radius

    static let radiusXS: CGFloat = 4
    static let radiusS: CGFloat = 8
    static let radiusM: CGFloat = 12
    static let radiusL: CGFloat = 16
    static let radiusXL: CGFloat = 24
    static let radiusXXL: CGFloat = 32
    static let radiusFull: CGFloat = 9999

    // MARK: - Shadows

    static let shadowLight = Color.black.opacity(0.2)
    static let shadowMedium = Color.black.opacity(0.35)
    static let shadowHeavy = Color.black.opacity(0.5)

    // MARK: - Animation

    static let animationFast: Animation = .easeInOut(duration: 0.15)
    static let animationDefault: Animation = .easeInOut(duration: 0.25)
    static let animationSlow: Animation = .easeInOut(duration: 0.4)
    static let animationSpring: Animation = .spring(response: 0.35, dampingFraction: 0.7)
    static let animationBouncy: Animation = .spring(response: 0.4, dampingFraction: 0.6)

    // MARK: - Blur Radii

    static let blurLight: CGFloat = 10
    static let blurMedium: CGFloat = 20
    static let blurHeavy: CGFloat = 40

    // MARK: - Icon Sizes

    static let iconS: CGFloat = 16
    static let iconM: CGFloat = 20
    static let iconL: CGFloat = 24
    static let iconXL: CGFloat = 32
    static let iconXXL: CGFloat = 48
}

// MARK: - Color Helpers

extension Color {
    static let themePrimary = Theme.textPrimary
    static let themeSecondary = Theme.textSecondary
    static let themeTertiary = Theme.textTertiary
    static let themeBackground = Theme.background
    static let themeSurface = Theme.surface
}

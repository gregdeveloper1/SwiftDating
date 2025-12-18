import SwiftUI

// MARK: - Glass Background Modifier

struct GlassBackground: ViewModifier {
    var material: Material
    var cornerRadius: CGFloat
    var strokeWidth: CGFloat
    var showGradientBorder: Bool

    init(
        material: Material = .ultraThinMaterial,
        cornerRadius: CGFloat = Theme.radiusL,
        strokeWidth: CGFloat = 0.5,
        showGradientBorder: Bool = true
    ) {
        self.material = material
        self.cornerRadius = cornerRadius
        self.strokeWidth = strokeWidth
        self.showGradientBorder = showGradientBorder
    }

    func body(content: Content) -> some View {
        content
            .background(material, in: RoundedRectangle(cornerRadius: cornerRadius))
            .overlay {
                if showGradientBorder {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: strokeWidth
                        )
                }
            }
            .shadow(color: Theme.shadowLight, radius: 10, x: 0, y: 5)
    }
}

// MARK: - Glass Card Modifier

struct GlassCardModifier: ViewModifier {
    var padding: CGFloat
    var material: Material
    var cornerRadius: CGFloat

    init(
        padding: CGFloat = Theme.spacingM,
        material: Material = .ultraThinMaterial,
        cornerRadius: CGFloat = Theme.radiusL
    ) {
        self.padding = padding
        self.material = material
        self.cornerRadius = cornerRadius
    }

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .modifier(GlassBackground(material: material, cornerRadius: cornerRadius))
    }
}

// MARK: - Glass Capsule Modifier

struct GlassCapsule: ViewModifier {
    var material: Material
    var strokeWidth: CGFloat

    init(material: Material = .ultraThinMaterial, strokeWidth: CGFloat = 0.5) {
        self.material = material
        self.strokeWidth = strokeWidth
    }

    func body(content: Content) -> some View {
        content
            .background(material, in: Capsule())
            .overlay {
                Capsule()
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: strokeWidth
                    )
            }
            .shadow(color: Theme.shadowLight, radius: 8, x: 0, y: 4)
    }
}

// MARK: - Gradient Border Modifier

struct GradientBorder: ViewModifier {
    var cornerRadius: CGFloat
    var lineWidth: CGFloat
    var colors: [Color]

    init(
        cornerRadius: CGFloat = Theme.radiusL,
        lineWidth: CGFloat = 1,
        colors: [Color] = [Color.white.opacity(0.4), Color.white.opacity(0.1)]
    ) {
        self.cornerRadius = cornerRadius
        self.lineWidth = lineWidth
        self.colors = colors
    }

    func body(content: Content) -> some View {
        content
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(
                        LinearGradient(
                            colors: colors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: lineWidth
                    )
            }
    }
}

// MARK: - Frosted Overlay Modifier

struct FrostedOverlay: ViewModifier {
    var alignment: Alignment
    var material: Material

    init(alignment: Alignment = .bottom, material: Material = .ultraThinMaterial) {
        self.alignment = alignment
        self.material = material
    }

    func body(content: Content) -> some View {
        content
            .background(alignment: alignment) {
                Rectangle()
                    .fill(material)
                    .mask {
                        switch alignment {
                        case .bottom, .bottomLeading, .bottomTrailing:
                            LinearGradient(
                                colors: [.clear, .black],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        case .top, .topLeading, .topTrailing:
                            LinearGradient(
                                colors: [.black, .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        default:
                            Color.black
                        }
                    }
            }
    }
}

// MARK: - Glow Effect Modifier

struct GlowEffect: ViewModifier {
    var color: Color
    var radius: CGFloat

    init(color: Color = .white.opacity(0.5), radius: CGFloat = 20) {
        self.color = color
        self.radius = radius
    }

    func body(content: Content) -> some View {
        content
            .shadow(color: color, radius: radius / 2)
            .shadow(color: color.opacity(0.5), radius: radius)
    }
}

// MARK: - View Extensions

extension View {
    /// Applies a glass background with material and gradient border
    func glassBackground(
        material: Material = .ultraThinMaterial,
        cornerRadius: CGFloat = Theme.radiusL,
        strokeWidth: CGFloat = 0.5,
        showGradientBorder: Bool = true
    ) -> some View {
        modifier(GlassBackground(
            material: material,
            cornerRadius: cornerRadius,
            strokeWidth: strokeWidth,
            showGradientBorder: showGradientBorder
        ))
    }

    /// Applies glass card styling with padding
    func glassCard(
        padding: CGFloat = Theme.spacingM,
        material: Material = .ultraThinMaterial,
        cornerRadius: CGFloat = Theme.radiusL
    ) -> some View {
        modifier(GlassCardModifier(
            padding: padding,
            material: material,
            cornerRadius: cornerRadius
        ))
    }

    /// Applies glass capsule styling
    func glassCapsule(
        material: Material = .ultraThinMaterial,
        strokeWidth: CGFloat = 0.5
    ) -> some View {
        modifier(GlassCapsule(material: material, strokeWidth: strokeWidth))
    }

    /// Applies a gradient border
    func gradientBorder(
        cornerRadius: CGFloat = Theme.radiusL,
        lineWidth: CGFloat = 1,
        colors: [Color] = [Color.white.opacity(0.4), Color.white.opacity(0.1)]
    ) -> some View {
        modifier(GradientBorder(
            cornerRadius: cornerRadius,
            lineWidth: lineWidth,
            colors: colors
        ))
    }

    /// Applies a frosted overlay gradient
    func frostedOverlay(
        alignment: Alignment = .bottom,
        material: Material = .ultraThinMaterial
    ) -> some View {
        modifier(FrostedOverlay(alignment: alignment, material: material))
    }

    /// Applies a glow effect
    func glowEffect(
        color: Color = .white.opacity(0.5),
        radius: CGFloat = 20
    ) -> some View {
        modifier(GlowEffect(color: color, radius: radius))
    }
}

// MARK: - Shape Extensions

extension Shape {
    /// Creates a glass-style fill with material
    func glassFill(_ material: Material = .ultraThinMaterial) -> some View {
        self.fill(material)
    }
}

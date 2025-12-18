import SwiftUI

// MARK: - Glass Button Styles

/// Primary glass button style with frosted background
struct GlassButtonStyle: ButtonStyle {
    var size: GlassButtonSize
    var isDestructive: Bool
    var isFullWidth: Bool

    init(
        size: GlassButtonSize = .medium,
        isDestructive: Bool = false,
        isFullWidth: Bool = false
    ) {
        self.size = size
        self.isDestructive = isDestructive
        self.isFullWidth = isFullWidth
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(size.font)
            .foregroundColor(Theme.textPrimary)
            .padding(.horizontal, size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay {
                Capsule()
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(configuration.isPressed ? 0.5 : 0.3),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            }
            .shadow(
                color: Theme.shadowLight,
                radius: configuration.isPressed ? 4 : 8,
                x: 0,
                y: configuration.isPressed ? 2 : 4
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(Theme.animationFast, value: configuration.isPressed)
    }
}

/// Solid glass button with filled background
struct SolidGlassButtonStyle: ButtonStyle {
    var size: GlassButtonSize
    var isFullWidth: Bool

    init(size: GlassButtonSize = .medium, isFullWidth: Bool = false) {
        self.size = size
        self.isFullWidth = isFullWidth
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(size.font.weight(.semibold))
            .foregroundColor(.black)
            .padding(.horizontal, size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .background(Color.white, in: Capsule())
            .shadow(
                color: Color.white.opacity(0.3),
                radius: configuration.isPressed ? 4 : 10,
                x: 0,
                y: configuration.isPressed ? 2 : 4
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(Theme.animationFast, value: configuration.isPressed)
    }
}

/// Outline glass button with border only
struct OutlineGlassButtonStyle: ButtonStyle {
    var size: GlassButtonSize
    var isFullWidth: Bool

    init(size: GlassButtonSize = .medium, isFullWidth: Bool = false) {
        self.size = size
        self.isFullWidth = isFullWidth
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(size.font)
            .foregroundColor(Theme.textPrimary)
            .padding(.horizontal, size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .background(
                configuration.isPressed ? Theme.surface : Color.clear,
                in: Capsule()
            )
            .overlay {
                Capsule()
                    .strokeBorder(
                        Theme.border,
                        lineWidth: configuration.isPressed ? 1.5 : 1
                    )
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(Theme.animationFast, value: configuration.isPressed)
    }
}

// MARK: - Button Size Configuration

enum GlassButtonSize {
    case small
    case medium
    case large

    var font: Font {
        switch self {
        case .small: return Theme.caption
        case .medium: return Theme.body
        case .large: return Theme.headline
        }
    }

    var horizontalPadding: CGFloat {
        switch self {
        case .small: return Theme.spacingM
        case .medium: return Theme.spacingL
        case .large: return Theme.spacingXL
        }
    }

    var verticalPadding: CGFloat {
        switch self {
        case .small: return Theme.spacingS
        case .medium: return Theme.spacingM
        case .large: return Theme.spacingM + Theme.spacingXS
        }
    }
}

// MARK: - Button Style Extensions

extension ButtonStyle where Self == GlassButtonStyle {
    static var glass: GlassButtonStyle { GlassButtonStyle() }
    static var glassSmall: GlassButtonStyle { GlassButtonStyle(size: .small) }
    static var glassLarge: GlassButtonStyle { GlassButtonStyle(size: .large) }
    static var glassFullWidth: GlassButtonStyle { GlassButtonStyle(isFullWidth: true) }
    static var glassDestructive: GlassButtonStyle { GlassButtonStyle(isDestructive: true) }
}

extension ButtonStyle where Self == SolidGlassButtonStyle {
    static var solidGlass: SolidGlassButtonStyle { SolidGlassButtonStyle() }
    static var solidGlassFullWidth: SolidGlassButtonStyle { SolidGlassButtonStyle(isFullWidth: true) }
}

extension ButtonStyle where Self == OutlineGlassButtonStyle {
    static var outlineGlass: OutlineGlassButtonStyle { OutlineGlassButtonStyle() }
    static var outlineGlassFullWidth: OutlineGlassButtonStyle { OutlineGlassButtonStyle(isFullWidth: true) }
}

// MARK: - Icon Button

struct GlassIconButton: View {
    let systemName: String
    let action: () -> Void
    var size: CGFloat
    var isCircle: Bool

    @State private var isPressed = false

    init(
        systemName: String,
        size: CGFloat = 44,
        isCircle: Bool = true,
        action: @escaping () -> Void
    ) {
        self.systemName = systemName
        self.size = size
        self.isCircle = isCircle
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: size * 0.4, weight: .medium))
                .foregroundStyle(Theme.textPrimary)
                .frame(width: size, height: size)
                .background(.ultraThinMaterial, in: shape)
                .overlay {
                    shape
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(isPressed ? 0.5 : 0.3),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                }
                .shadow(color: Theme.shadowLight, radius: isPressed ? 4 : 8)
                .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(Theme.animationFast) { isPressed = true }
                }
                .onEnded { _ in
                    withAnimation(Theme.animationFast) { isPressed = false }
                }
        )
    }

    @ViewBuilder
    private var shape: some Shape {
        if isCircle {
            AnyShape(Circle())
        } else {
            AnyShape(RoundedRectangle(cornerRadius: Theme.radiusM))
        }
    }
}

// MARK: - AnyShape Helper

struct AnyShape: Shape {
    private let pathBuilder: (CGRect) -> Path

    init<S: Shape>(_ shape: S) {
        pathBuilder = { rect in
            shape.path(in: rect)
        }
    }

    func path(in rect: CGRect) -> Path {
        pathBuilder(rect)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Theme.background.ignoresSafeArea()

        VStack(spacing: Theme.spacingL) {
            Button("Glass Button") {}
                .buttonStyle(.glass)

            Button("Solid Glass Button") {}
                .buttonStyle(.solidGlass)

            Button("Outline Button") {}
                .buttonStyle(.outlineGlass)

            Button("Full Width") {}
                .buttonStyle(.glassFullWidth)
                .padding(.horizontal)

            Button("Full Width Solid") {}
                .buttonStyle(.solidGlassFullWidth)
                .padding(.horizontal)

            HStack(spacing: Theme.spacingM) {
                GlassIconButton(systemName: "heart.fill") {}
                GlassIconButton(systemName: "xmark") {}
                GlassIconButton(systemName: "star.fill") {}
            }
        }
    }
}

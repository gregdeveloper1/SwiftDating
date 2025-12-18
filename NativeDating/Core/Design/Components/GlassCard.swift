import SwiftUI

/// A reusable glass card container with frosted glass effect
struct GlassCard<Content: View>: View {
    let content: Content
    var material: Material
    var cornerRadius: CGFloat
    var padding: CGFloat
    var shadowRadius: CGFloat

    init(
        material: Material = .ultraThinMaterial,
        cornerRadius: CGFloat = Theme.radiusXL,
        padding: CGFloat = Theme.spacingM,
        shadowRadius: CGFloat = 20,
        @ViewBuilder content: () -> Content
    ) {
        self.material = material
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.shadowRadius = shadowRadius
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(material, in: RoundedRectangle(cornerRadius: cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.4),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            }
            .shadow(color: Color.black.opacity(0.25), radius: shadowRadius, x: 0, y: 10)
    }
}

/// A glass card variant optimized for list items
struct GlassListCard<Content: View>: View {
    let content: Content
    var isSelected: Bool

    init(isSelected: Bool = false, @ViewBuilder content: () -> Content) {
        self.isSelected = isSelected
        self.content = content()
    }

    var body: some View {
        content
            .padding(Theme.spacingM)
            .background {
                RoundedRectangle(cornerRadius: Theme.radiusL)
                    .fill(isSelected ? Theme.surfaceActive : Theme.surface)
            }
            .overlay {
                RoundedRectangle(cornerRadius: Theme.radiusL)
                    .strokeBorder(
                        isSelected ? Theme.border : Theme.borderLight,
                        lineWidth: isSelected ? 1 : 0.5
                    )
            }
    }
}

/// A glass card with interactive hover/press states
struct InteractiveGlassCard<Content: View>: View {
    let content: Content
    let action: () -> Void

    @State private var isPressed = false

    init(action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.action = action
        self.content = content()
    }

    var body: some View {
        Button(action: action) {
            content
                .padding(Theme.spacingM)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Theme.radiusL))
                .overlay {
                    RoundedRectangle(cornerRadius: Theme.radiusL)
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
                .shadow(color: Theme.shadowLight, radius: isPressed ? 5 : 15, x: 0, y: isPressed ? 2 : 8)
                .scaleEffect(isPressed ? 0.98 : 1.0)
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
}

#Preview {
    ZStack {
        Theme.background.ignoresSafeArea()

        VStack(spacing: Theme.spacingL) {
            GlassCard {
                VStack(alignment: .leading, spacing: Theme.spacingS) {
                    Text("Glass Card")
                        .font(Theme.title3)
                        .foregroundStyle(Theme.textPrimary)
                    Text("A beautiful frosted glass effect")
                        .font(Theme.body)
                        .foregroundStyle(Theme.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            GlassListCard(isSelected: true) {
                HStack {
                    Text("Selected List Item")
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                    Image(systemName: "checkmark")
                        .foregroundStyle(Theme.textPrimary)
                }
            }

            InteractiveGlassCard(action: {}) {
                HStack {
                    Image(systemName: "hand.tap")
                    Text("Tap me")
                }
                .foregroundStyle(Theme.textPrimary)
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
    }
}

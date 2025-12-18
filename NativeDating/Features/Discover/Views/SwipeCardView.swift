import SwiftUI

struct SwipeCardView: View {
    let user: User
    let onSwipe: (SwipeDirection) -> Void
    let onTap: () -> Void

    @State private var offset: CGSize = .zero
    @State private var rotation: Double = 0
    @State private var currentPhotoIndex = 0
    @GestureState private var isDragging = false

    private let swipeThreshold: CGFloat = Constants.swipeThreshold
    private let maxRotation: Double = Constants.maxRotation

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Photo carousel
                photoCarousel(size: geometry.size)

                // Gradient overlay
                gradientOverlay

                // User info
                userInfoOverlay
                    .padding(Theme.spacingL)

                // Swipe indicators
                swipeIndicators
            }
            .clipShape(RoundedRectangle(cornerRadius: Theme.radiusXXL))
            .overlay {
                RoundedRectangle(cornerRadius: Theme.radiusXXL)
                    .strokeBorder(
                        LinearGradient(
                            colors: [.white.opacity(0.2), .white.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 0.5
                    )
            }
            .shadow(color: Theme.shadowHeavy, radius: 30, x: 0, y: 15)
            .offset(offset)
            .rotationEffect(.degrees(rotation))
            .gesture(dragGesture)
            .onTapGesture {
                onTap()
            }
            .animation(.interactiveSpring(response: 0.4, dampingFraction: 0.7), value: offset)
        }
    }

    // MARK: - Photo Carousel

    @ViewBuilder
    private func photoCarousel(size: CGSize) -> some View {
        ZStack {
            // Photos
            TabView(selection: $currentPhotoIndex) {
                ForEach(Array(user.photoURLs.enumerated()), id: \.offset) { index, url in
                    AsyncImage(url: URL(string: url)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            placeholderView
                        case .empty:
                            ProgressView()
                                .tint(Theme.textSecondary)
                        @unknown default:
                            placeholderView
                        }
                    }
                    .frame(width: size.width, height: size.height)
                    .clipped()
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Photo indicators
            VStack {
                photoIndicators
                    .padding(.top, Theme.spacingM)
                Spacer()
            }

            // Tap zones for photo navigation
            HStack(spacing: 0) {
                // Previous photo tap zone
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if currentPhotoIndex > 0 {
                            withAnimation {
                                currentPhotoIndex -= 1
                            }
                            Haptics.lightImpact()
                        }
                    }

                // Next photo tap zone
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if currentPhotoIndex < user.photoURLs.count - 1 {
                            withAnimation {
                                currentPhotoIndex += 1
                            }
                            Haptics.lightImpact()
                        }
                    }
            }
        }
    }

    private var placeholderView: some View {
        Rectangle()
            .fill(Theme.surface)
            .overlay {
                Image(systemName: "person.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(Theme.textTertiary)
            }
    }

    private var photoIndicators: some View {
        HStack(spacing: Theme.spacingXS) {
            ForEach(0..<user.photoURLs.count, id: \.self) { index in
                Capsule()
                    .fill(index == currentPhotoIndex ? Color.white : Color.white.opacity(0.4))
                    .frame(height: 3)
                    .animation(.easeInOut(duration: 0.2), value: currentPhotoIndex)
            }
        }
        .padding(.horizontal, Theme.spacingM)
    }

    // MARK: - Gradient Overlay

    private var gradientOverlay: some View {
        LinearGradient(
            colors: [
                .clear,
                .clear,
                .black.opacity(0.3),
                .black.opacity(0.8)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - User Info

    private var userInfoOverlay: some View {
        VStack(alignment: .leading, spacing: Theme.spacingS) {
            // Name and age
            HStack(alignment: .firstTextBaseline, spacing: Theme.spacingS) {
                Text(user.displayName)
                    .font(Theme.title)

                Text("\(user.age)")
                    .font(Theme.title2)
                    .foregroundStyle(Theme.textSecondary)

                if user.isVerified {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Theme.textPrimary)
                }

                Spacer()
            }

            // Location
            if let location = user.locationString {
                HStack(spacing: Theme.spacingXS) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 12))
                    Text(location)
                        .font(Theme.subheadline)
                }
                .foregroundStyle(Theme.textSecondary)
            }

            // Bio
            if let bio = user.bio {
                Text(bio)
                    .font(Theme.body)
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(2)
            }

            // Interests
            if !user.interests.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Theme.spacingS) {
                        ForEach(user.interests.prefix(5), id: \.self) { interest in
                            Text(interest)
                                .font(Theme.caption)
                                .foregroundStyle(Theme.textPrimary)
                                .padding(.horizontal, Theme.spacingS)
                                .padding(.vertical, Theme.spacingXS)
                                .background(.ultraThinMaterial, in: Capsule())
                        }
                    }
                }
            }
        }
        .foregroundStyle(Theme.textPrimary)
    }

    // MARK: - Swipe Indicators

    private var swipeIndicators: some View {
        ZStack {
            // LIKE indicator (right swipe)
            likeIndicator
                .opacity(likeOpacity)
                .offset(x: -40, y: -120)

            // NOPE indicator (left swipe)
            nopeIndicator
                .opacity(nopeOpacity)
                .offset(x: 40, y: -120)
        }
    }

    private var likeIndicator: some View {
        Text("LIKE")
            .font(.system(size: 40, weight: .black))
            .foregroundStyle(.white)
            .padding(.horizontal, Theme.spacingL)
            .padding(.vertical, Theme.spacingS)
            .overlay {
                RoundedRectangle(cornerRadius: Theme.radiusM)
                    .strokeBorder(.white, lineWidth: 4)
            }
            .rotationEffect(.degrees(-15))
    }

    private var nopeIndicator: some View {
        Text("NOPE")
            .font(.system(size: 40, weight: .black))
            .foregroundStyle(.white)
            .padding(.horizontal, Theme.spacingL)
            .padding(.vertical, Theme.spacingS)
            .overlay {
                RoundedRectangle(cornerRadius: Theme.radiusM)
                    .strokeBorder(.white, lineWidth: 4)
            }
            .rotationEffect(.degrees(15))
    }

    // MARK: - Opacity Calculations

    private var likeOpacity: Double {
        max(0, min(Double(offset.width) / swipeThreshold, 1.0))
    }

    private var nopeOpacity: Double {
        max(0, min(Double(-offset.width) / swipeThreshold, 1.0))
    }

    // MARK: - Drag Gesture

    private var dragGesture: some Gesture {
        DragGesture()
            .updating($isDragging) { _, state, _ in
                state = true
            }
            .onChanged { value in
                offset = value.translation
                rotation = Double(value.translation.width / 20).clamped(to: -maxRotation...maxRotation)
            }
            .onEnded { value in
                let horizontalAmount = value.translation.width

                if abs(horizontalAmount) > swipeThreshold {
                    // Swipe completed
                    let direction: SwipeDirection = horizontalAmount > 0 ? .like : .nope

                    // Animate off screen
                    withAnimation(.easeOut(duration: Constants.swipeAnimationDuration)) {
                        offset = CGSize(
                            width: horizontalAmount > 0 ? 500 : -500,
                            height: value.translation.height
                        )
                        rotation = horizontalAmount > 0 ? 15 : -15
                    }

                    // Haptic feedback
                    if direction == .like {
                        Haptics.swipeLike()
                    } else {
                        Haptics.swipeNope()
                    }

                    // Callback after animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + Constants.swipeAnimationDuration) {
                        onSwipe(direction)
                    }
                } else {
                    // Reset position
                    withAnimation(Theme.animationSpring) {
                        offset = .zero
                        rotation = 0
                    }
                }
            }
    }
}

// MARK: - Clamped Extension

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Theme.background.ignoresSafeArea()

        SwipeCardView(
            user: .mock,
            onSwipe: { direction in
                print("Swiped: \(direction)")
            },
            onTap: {
                print("Tapped")
            }
        )
        .padding()
    }
}

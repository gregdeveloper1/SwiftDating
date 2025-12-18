import SwiftUI

struct CardStackView: View {
    @Binding var users: [User]
    let onSwipe: (User, SwipeDirection) -> Void
    let onProfileTap: (User) -> Void
    let onRefresh: () async -> Void

    @State private var topCardOffset: CGSize = .zero

    var body: some View {
        ZStack {
            if users.isEmpty {
                emptyStateView
            } else {
                // Background cards (show up to 2 behind)
                ForEach(Array(users.prefix(3).enumerated().reversed()), id: \.element.id) { index, user in
                    cardView(for: user, at: index)
                }
            }
        }
    }

    // MARK: - Card View

    @ViewBuilder
    private func cardView(for user: User, at index: Int) -> some View {
        let isTopCard = index == 0
        let scale = 1.0 - (Double(index) * 0.05)
        let yOffset = Double(index) * 10

        SwipeCardView(
            user: user,
            onSwipe: { direction in
                withAnimation(.easeOut(duration: 0.2)) {
                    users.removeFirst()
                }
                onSwipe(user, direction)
            },
            onTap: {
                onProfileTap(user)
            }
        )
        .scaleEffect(scale)
        .offset(y: yOffset)
        .allowsHitTesting(isTopCard)
        .zIndex(Double(users.count - index))
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: Theme.spacingL) {
            Image(systemName: "sparkles")
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(Theme.textTertiary)

            VStack(spacing: Theme.spacingS) {
                Text("No more profiles")
                    .font(Theme.title2)
                    .foregroundStyle(Theme.textPrimary)

                Text("Check back later or expand your preferences")
                    .font(Theme.body)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                Task {
                    await onRefresh()
                }
                Haptics.buttonTap()
            } label: {
                HStack(spacing: Theme.spacingS) {
                    Image(systemName: "arrow.clockwise")
                    Text("Refresh")
                }
            }
            .buttonStyle(.glass)
        }
        .padding(Theme.spacingXL)
    }
}

// MARK: - Discover View (Full Implementation)

struct DiscoverViewFull: View {
    @State private var users: [User] = []
    @State private var isLoading = false
    @State private var showProfile: User?
    @State private var showNewMatch: Match?

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                headerView
                    .padding(.horizontal, Theme.spacingL)
                    .padding(.top, Theme.spacingS)

                // Card stack
                CardStackView(
                    users: $users,
                    onSwipe: handleSwipe,
                    onProfileTap: { user in
                        showProfile = user
                    },
                    onRefresh: loadUsers
                )
                .padding(.horizontal, Theme.spacingM)
                .padding(.vertical, Theme.spacingM)

                // Action buttons
                actionButtons
                    .padding(.horizontal, Theme.spacingXL)
                    .padding(.bottom, Theme.spacingM)
            }
        }
        .sheet(item: $showProfile) { user in
            ProfileDetailView(user: user)
        }
        .fullScreenCover(item: $showNewMatch) { match in
            NewMatchView(match: match) {
                showNewMatch = nil
            }
        }
        .task {
            await loadUsers()
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            Text("Discover")
                .font(Theme.title)
                .foregroundStyle(Theme.textPrimary)

            Spacer()

            // Filter button
            GlassIconButton(systemName: "slider.horizontal.3", size: 40) {
                // Show filters
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: Theme.spacingL) {
            // Rewind button
            actionButton(icon: "arrow.uturn.backward", size: 50) {
                // Rewind last swipe (premium feature)
            }

            // Nope button
            actionButton(icon: "xmark", size: 64, isPrimary: false) {
                swipeTopCard(.nope)
            }

            // Super Like button
            actionButton(icon: "star.fill", size: 50) {
                swipeTopCard(.superLike)
            }

            // Like button
            actionButton(icon: "heart.fill", size: 64, isPrimary: true) {
                swipeTopCard(.like)
            }

            // Boost button
            actionButton(icon: "bolt.fill", size: 50) {
                // Boost profile (premium feature)
            }
        }
    }

    @ViewBuilder
    private func actionButton(
        icon: String,
        size: CGFloat,
        isPrimary: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundStyle(isPrimary ? .black : Theme.textPrimary)
                .frame(width: size, height: size)
                .background(
                    isPrimary ? Color.white : .ultraThinMaterial,
                    in: Circle()
                )
                .overlay {
                    Circle()
                        .strokeBorder(
                            isPrimary
                            ? Color.clear
                            : LinearGradient(
                                colors: [.white.opacity(0.3), .white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                }
                .shadow(color: isPrimary ? .white.opacity(0.3) : Theme.shadowLight, radius: 10)
        }
        .buttonStyle(.plain)
        .disabled(users.isEmpty)
        .opacity(users.isEmpty ? 0.5 : 1)
    }

    // MARK: - Actions

    private func swipeTopCard(_ direction: SwipeDirection) {
        guard let topUser = users.first else { return }

        // Haptic feedback
        switch direction {
        case .like:
            Haptics.swipeLike()
        case .nope:
            Haptics.swipeNope()
        case .superLike:
            Haptics.superLike()
        }

        // Remove from stack
        withAnimation(.easeOut(duration: 0.3)) {
            users.removeFirst()
        }

        // Handle the swipe
        handleSwipe(user: topUser, direction: direction)
    }

    private func handleSwipe(user: User, direction: SwipeDirection) {
        Task {
            // TODO: Send swipe to backend
            // let match = try await matchService.swipe(userId: user.id, direction: direction)
            // if let match = match {
            //     showNewMatch = match
            // }
            print("Swiped \(direction) on \(user.displayName)")
        }
    }

    private func loadUsers() async {
        isLoading = true
        defer { isLoading = false }

        // TODO: Load from backend
        // For now, use mock data
        users = [.mock, .mock, .mock]
    }
}

// MARK: - Profile Detail View (Placeholder)

struct ProfileDetailView: View {
    let user: User
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.spacingL) {
                    // Photos
                    TabView {
                        ForEach(user.photoURLs, id: \.self) { url in
                            AsyncImage(url: URL(string: url)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Rectangle()
                                    .fill(Theme.surface)
                            }
                        }
                    }
                    .tabViewStyle(.page)
                    .frame(height: 400)

                    // Info
                    VStack(alignment: .leading, spacing: Theme.spacingM) {
                        // Name and basics
                        HStack(alignment: .firstTextBaseline) {
                            Text(user.displayName)
                                .font(Theme.title)
                            Text("\(user.age)")
                                .font(Theme.title2)
                                .foregroundStyle(Theme.textSecondary)
                        }

                        if let bio = user.bio {
                            Text(bio)
                                .font(Theme.body)
                                .foregroundStyle(Theme.textSecondary)
                        }

                        // Details
                        if let job = user.jobTitle {
                            detailRow(icon: "briefcase", text: job)
                        }
                        if let education = user.education {
                            detailRow(icon: "graduationcap", text: education)
                        }
                        if let location = user.locationString {
                            detailRow(icon: "location", text: location)
                        }

                        // Prompts
                        ForEach(user.prompts) { prompt in
                            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                                Text(prompt.promptText)
                                    .font(Theme.subheadline)
                                    .foregroundStyle(Theme.textTertiary)
                                Text(prompt.answer)
                                    .font(Theme.body)
                                    .foregroundStyle(Theme.textPrimary)
                            }
                            .padding(Theme.spacingM)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .glassBackground(cornerRadius: Theme.radiusL)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .background(Theme.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
            }
        }
        .foregroundStyle(Theme.textPrimary)
    }

    @ViewBuilder
    private func detailRow(icon: String, text: String) -> some View {
        HStack(spacing: Theme.spacingS) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(Theme.textTertiary)
                .frame(width: 20)
            Text(text)
                .font(Theme.body)
                .foregroundStyle(Theme.textSecondary)
        }
    }
}

// MARK: - New Match View

struct NewMatchView: View {
    let match: Match
    let onDismiss: () -> Void

    @State private var showAnimation = false

    var body: some View {
        ZStack {
            // Background
            Theme.background
                .ignoresSafeArea()
                .overlay {
                    // Particle effect placeholder
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.white.opacity(0.1), .clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 300
                            )
                        )
                        .scaleEffect(showAnimation ? 2 : 0.5)
                        .opacity(showAnimation ? 0 : 1)
                }

            VStack(spacing: Theme.spacingXL) {
                Spacer()

                // Hearts animation
                HStack(spacing: -30) {
                    profileCircle(url: match.otherUser?.photoURLs.first)
                        .offset(x: showAnimation ? 0 : -50)
                        .opacity(showAnimation ? 1 : 0)

                    Image(systemName: "heart.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.white)
                        .scaleEffect(showAnimation ? 1 : 0)

                    profileCircle(url: nil) // Current user
                        .offset(x: showAnimation ? 0 : 50)
                        .opacity(showAnimation ? 1 : 0)
                }

                // Text
                VStack(spacing: Theme.spacingS) {
                    Text("It's a Match!")
                        .font(Theme.largeTitle)
                        .foregroundStyle(Theme.textPrimary)
                        .scaleEffect(showAnimation ? 1 : 0.5)
                        .opacity(showAnimation ? 1 : 0)

                    Text("You and \(match.otherUser?.displayName ?? "someone") liked each other")
                        .font(Theme.body)
                        .foregroundStyle(Theme.textSecondary)
                        .opacity(showAnimation ? 1 : 0)
                }

                Spacer()

                // Buttons
                VStack(spacing: Theme.spacingM) {
                    Button {
                        // Send message
                        onDismiss()
                    } label: {
                        Text("Send Message")
                    }
                    .buttonStyle(.solidGlassFullWidth)

                    Button {
                        onDismiss()
                    } label: {
                        Text("Keep Swiping")
                    }
                    .buttonStyle(.glassFullWidth)
                }
                .padding(.horizontal, Theme.spacingL)
                .opacity(showAnimation ? 1 : 0)
                .offset(y: showAnimation ? 0 : 50)
            }
            .padding(.bottom, Theme.spacingXL)
        }
        .onAppear {
            Haptics.newMatch()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showAnimation = true
            }
        }
    }

    @ViewBuilder
    private func profileCircle(url: String?) -> some View {
        AsyncImage(url: url.flatMap { URL(string: $0) }) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Circle()
                .fill(Theme.surface)
        }
        .frame(width: 120, height: 120)
        .clipShape(Circle())
        .overlay {
            Circle()
                .strokeBorder(.white, lineWidth: 3)
        }
        .shadow(color: Theme.shadowMedium, radius: 20)
    }
}

// MARK: - Preview

#Preview {
    DiscoverViewFull()
}

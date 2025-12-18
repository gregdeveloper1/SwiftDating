import SwiftUI

// MARK: - Tab Item Definition

enum TabItem: Int, CaseIterable, Identifiable {
    case discover
    case browse
    case community
    case matches
    case profile

    var id: Int { rawValue }

    var icon: String {
        switch self {
        case .discover: return "sparkles"
        case .browse: return "square.grid.2x2"
        case .community: return "bubble.left.and.bubble.right"
        case .matches: return "heart"
        case .profile: return "person"
        }
    }

    var selectedIcon: String {
        switch self {
        case .discover: return "sparkles"
        case .browse: return "square.grid.2x2.fill"
        case .community: return "bubble.left.and.bubble.right.fill"
        case .matches: return "heart.fill"
        case .profile: return "person.fill"
        }
    }

    var title: String {
        switch self {
        case .discover: return "Discover"
        case .browse: return "Browse"
        case .community: return "Community"
        case .matches: return "Matches"
        case .profile: return "Profile"
        }
    }
}

// MARK: - Glass Tab Bar

struct GlassTabBar: View {
    @Binding var selectedTab: TabItem
    var unreadCounts: [TabItem: Int]
    var onTabTapped: ((TabItem) -> Void)?

    init(
        selectedTab: Binding<TabItem>,
        unreadCounts: [TabItem: Int] = [:],
        onTabTapped: ((TabItem) -> Void)? = nil
    ) {
        self._selectedTab = selectedTab
        self.unreadCounts = unreadCounts
        self.onTabTapped = onTabTapped
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabItem.allCases) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, Theme.spacingS)
        .padding(.vertical, Theme.spacingS)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay {
            Capsule()
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.2),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 0.5
                )
        }
        .shadow(color: Theme.shadowMedium, radius: 20, x: 0, y: 10)
        .padding(.horizontal, Theme.spacingL)
        .padding(.bottom, Theme.spacingS)
    }

    @ViewBuilder
    private func tabButton(for tab: TabItem) -> some View {
        let isSelected = selectedTab == tab

        Button {
            withAnimation(Theme.animationSpring) {
                selectedTab = tab
            }
            onTabTapped?(tab)
        } label: {
            VStack(spacing: Theme.spacingXS) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                        .font(.system(size: 22, weight: .medium))
                        .symbolEffect(.bounce, value: isSelected)

                    if let count = unreadCounts[tab], count > 0 {
                        badgeView(count: count)
                    }
                }

                Text(tab.title)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundStyle(isSelected ? Theme.textPrimary : Theme.textTertiary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.spacingS)
            .background {
                if isSelected {
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                }
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func badgeView(count: Int) -> some View {
        Text(count > 99 ? "99+" : "\(count)")
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(.black)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(Color.white, in: Capsule())
            .offset(x: 10, y: -4)
    }
}

// MARK: - Main Tab View Container

struct MainTabView: View {
    @State private var selectedTab: TabItem = .discover
    @State private var unreadCounts: [TabItem: Int] = [
        .matches: 3,
        .community: 5
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab content
            TabView(selection: $selectedTab) {
                ForEach(TabItem.allCases) { tab in
                    tabContent(for: tab)
                        .tag(tab)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Custom glass tab bar
            GlassTabBar(
                selectedTab: $selectedTab,
                unreadCounts: unreadCounts
            )
        }
        .ignoresSafeArea(.keyboard)
    }

    @ViewBuilder
    private func tabContent(for tab: TabItem) -> some View {
        switch tab {
        case .discover:
            DiscoverView()
        case .browse:
            BrowseView()
        case .community:
            FeedView()
        case .matches:
            MatchesView()
        case .profile:
            ProfileView()
        }
    }
}

// MARK: - Placeholder Views

struct DiscoverView: View {
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            Text("Discover")
                .font(Theme.title)
                .foregroundStyle(Theme.textPrimary)
        }
    }
}

struct BrowseView: View {
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            Text("Browse")
                .font(Theme.title)
                .foregroundStyle(Theme.textPrimary)
        }
    }
}

struct FeedView: View {
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            Text("Community")
                .font(Theme.title)
                .foregroundStyle(Theme.textPrimary)
        }
    }
}

struct MatchesView: View {
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            Text("Matches")
                .font(Theme.title)
                .foregroundStyle(Theme.textPrimary)
        }
    }
}

struct ProfileView: View {
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            Text("Profile")
                .font(Theme.title)
                .foregroundStyle(Theme.textPrimary)
        }
    }
}

// MARK: - Preview

#Preview {
    MainTabView()
        .preferredColorScheme(.dark)
}

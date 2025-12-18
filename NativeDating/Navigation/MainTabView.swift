import SwiftUI

// MARK: - Main Tab View (Updated Full Implementation)

struct MainTabViewFull: View {
    @State private var selectedTab: TabItem = .discover
    @State private var unreadCounts: [TabItem: Int] = [:]

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab content
            Group {
                switch selectedTab {
                case .discover:
                    DiscoverViewFull()
                case .browse:
                    BrowseViewFull()
                case .community:
                    CommunityFeedView()
                case .matches:
                    MatchesViewFull()
                case .profile:
                    ProfileViewFull()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Glass tab bar
            GlassTabBar(
                selectedTab: $selectedTab,
                unreadCounts: unreadCounts,
                onTabTapped: { tab in
                    Haptics.tabChange()
                }
            )
        }
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Browse View Full

struct BrowseViewFull: View {
    @State private var users: [User] = []
    @State private var searchText = ""
    @State private var viewMode: ViewMode = .grid
    @State private var showFilters = false

    enum ViewMode {
        case grid, list
    }

    private let columns = [
        GridItem(.flexible(), spacing: Theme.spacingS),
        GridItem(.flexible(), spacing: Theme.spacingS)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    headerView
                        .padding(.horizontal, Theme.spacingL)

                    // Search
                    GlassSearchField(text: $searchText)
                        .padding(.horizontal, Theme.spacingL)
                        .padding(.vertical, Theme.spacingS)

                    // Content
                    ScrollView {
                        if viewMode == .grid {
                            gridContent
                        } else {
                            listContent
                        }
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .sheet(isPresented: $showFilters) {
                FilterSheet()
            }
        }
    }

    private var headerView: some View {
        HStack {
            Text("Browse")
                .font(Theme.title)
                .foregroundStyle(Theme.textPrimary)

            Spacer()

            HStack(spacing: Theme.spacingS) {
                // View mode toggle
                Button {
                    withAnimation {
                        viewMode = viewMode == .grid ? .list : .grid
                    }
                    Haptics.selection()
                } label: {
                    Image(systemName: viewMode == .grid ? "list.bullet" : "square.grid.2x2")
                        .font(.system(size: Theme.iconM))
                        .foregroundStyle(Theme.textSecondary)
                }

                // Filter button
                GlassIconButton(systemName: "slider.horizontal.3", size: 40) {
                    showFilters = true
                }
            }
        }
    }

    private var gridContent: some View {
        LazyVGrid(columns: columns, spacing: Theme.spacingS) {
            ForEach(users) { user in
                BrowseUserCard(user: user, style: .grid)
            }
        }
        .padding(Theme.spacingM)
    }

    private var listContent: some View {
        LazyVStack(spacing: Theme.spacingS) {
            ForEach(users) { user in
                BrowseUserCard(user: user, style: .list)
            }
        }
        .padding(Theme.spacingM)
    }
}

// MARK: - Browse User Card

struct BrowseUserCard: View {
    let user: User
    let style: CardStyle

    enum CardStyle {
        case grid, list
    }

    var body: some View {
        Group {
            switch style {
            case .grid:
                gridCard
            case .list:
                listCard
            }
        }
    }

    private var gridCard: some View {
        ZStack(alignment: .bottomLeading) {
            // Photo
            AsyncImage(url: user.primaryPhotoURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Theme.surface)
            }

            // Gradient
            LinearGradient(
                colors: [.clear, .black.opacity(0.7)],
                startPoint: .center,
                endPoint: .bottom
            )

            // Info
            VStack(alignment: .leading, spacing: Theme.spacingXXS) {
                Text("\(user.displayName), \(user.age)")
                    .font(Theme.headline)
                    .foregroundStyle(Theme.textPrimary)

                if let location = user.city {
                    Text(location)
                        .font(Theme.caption)
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            .padding(Theme.spacingS)
        }
        .frame(height: 220)
        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusL))
        .overlay {
            RoundedRectangle(cornerRadius: Theme.radiusL)
                .strokeBorder(Theme.borderLight, lineWidth: 0.5)
        }
    }

    private var listCard: some View {
        HStack(spacing: Theme.spacingM) {
            // Photo
            AsyncImage(url: user.primaryPhotoURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Theme.surface)
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: Theme.radiusM))

            // Info
            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                HStack {
                    Text(user.displayName)
                        .font(Theme.headline)
                    Text("\(user.age)")
                        .font(Theme.body)
                        .foregroundStyle(Theme.textSecondary)
                }

                if let bio = user.bio {
                    Text(bio)
                        .font(Theme.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(2)
                }

                if let location = user.locationString {
                    HStack(spacing: Theme.spacingXS) {
                        Image(systemName: "location")
                            .font(.system(size: 10))
                        Text(location)
                            .font(Theme.caption)
                    }
                    .foregroundStyle(Theme.textTertiary)
                }
            }

            Spacer()

            // Like button
            GlassIconButton(systemName: "heart", size: 40) {
                // Like user
            }
        }
        .padding(Theme.spacingM)
        .glassBackground(cornerRadius: Theme.radiusL)
        .foregroundStyle(Theme.textPrimary)
    }
}

// MARK: - Filter Sheet

struct FilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var ageRange: ClosedRange<Double> = 18...50
    @State private var distance: Double = 50
    @State private var genderPreferences: Set<Gender> = [.woman]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.spacingXL) {
                    // Age range
                    VStack(alignment: .leading, spacing: Theme.spacingM) {
                        Text("Age Range")
                            .font(Theme.headline)
                            .foregroundStyle(Theme.textPrimary)

                        VStack(spacing: Theme.spacingS) {
                            HStack {
                                Text("\(Int(ageRange.lowerBound))")
                                Spacer()
                                Text("\(Int(ageRange.upperBound))")
                            }
                            .font(Theme.body)
                            .foregroundStyle(Theme.textSecondary)

                            // Note: SwiftUI doesn't have a built-in range slider
                            // You'd need to implement a custom one
                            Slider(value: .constant(ageRange.upperBound), in: 18...100)
                                .tint(.white)
                        }
                    }
                    .padding(Theme.spacingM)
                    .glassBackground(cornerRadius: Theme.radiusL)

                    // Distance
                    VStack(alignment: .leading, spacing: Theme.spacingM) {
                        HStack {
                            Text("Distance")
                                .font(Theme.headline)
                            Spacer()
                            Text("\(Int(distance)) km")
                                .font(Theme.body)
                                .foregroundStyle(Theme.textSecondary)
                        }
                        .foregroundStyle(Theme.textPrimary)

                        Slider(value: $distance, in: 1...500)
                            .tint(.white)
                    }
                    .padding(Theme.spacingM)
                    .glassBackground(cornerRadius: Theme.radiusL)

                    // Gender preferences
                    VStack(alignment: .leading, spacing: Theme.spacingM) {
                        Text("Show Me")
                            .font(Theme.headline)
                            .foregroundStyle(Theme.textPrimary)

                        ForEach(Gender.allCases) { gender in
                            filterToggle(gender)
                        }
                    }
                    .padding(Theme.spacingM)
                    .glassBackground(cornerRadius: Theme.radiusL)
                }
                .padding()
            }
            .background(Theme.background)
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Reset") {
                        // Reset filters
                    }
                    .foregroundStyle(Theme.textSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Apply") {
                        dismiss()
                    }
                    .foregroundStyle(Theme.textPrimary)
                }
            }
        }
    }

    @ViewBuilder
    private func filterToggle(_ gender: Gender) -> some View {
        let isSelected = genderPreferences.contains(gender)

        Button {
            if isSelected {
                genderPreferences.remove(gender)
            } else {
                genderPreferences.insert(gender)
            }
            Haptics.selection()
        } label: {
            HStack {
                Text(gender.displayName)
                    .font(Theme.body)
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
            }
            .foregroundStyle(isSelected ? Theme.textPrimary : Theme.textSecondary)
        }
    }
}

// MARK: - Community Feed View

struct CommunityFeedView: View {
    @State private var posts: [Post] = Post.mockPosts
    @State private var showCreatePost = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: Theme.spacingM) {
                        ForEach(posts) { post in
                            PostCard(post: post)
                        }
                    }
                    .padding()
                }
                .refreshable {
                    // Refresh posts
                }
            }
            .navigationTitle("Community")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCreatePost = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Theme.textPrimary)
                    }
                }
            }
            .sheet(isPresented: $showCreatePost) {
                CreatePostSheet()
            }
        }
    }
}

// MARK: - Post Card

struct PostCard: View {
    let post: Post
    @State private var isLiked: Bool

    init(post: Post) {
        self.post = post
        self._isLiked = State(initialValue: post.isLikedByCurrentUser)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacingM) {
            // Author
            HStack(spacing: Theme.spacingS) {
                AsyncImage(url: post.author?.primaryPhotoURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Theme.surface)
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())

                VStack(alignment: .leading, spacing: Theme.spacingXXS) {
                    Text(post.author?.displayName ?? "User")
                        .font(Theme.headline)
                        .foregroundStyle(Theme.textPrimary)

                    Text(post.formattedDate)
                        .font(Theme.caption)
                        .foregroundStyle(Theme.textTertiary)
                }

                Spacer()

                Menu {
                    Button("Report", role: .destructive) {}
                    Button("Block User", role: .destructive) {}
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(Theme.textTertiary)
                }
            }

            // Content
            Text(post.content)
                .font(Theme.body)
                .foregroundStyle(Theme.textPrimary)

            // Actions
            HStack(spacing: Theme.spacingL) {
                // Like
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isLiked.toggle()
                    }
                    Haptics.lightImpact()
                } label: {
                    HStack(spacing: Theme.spacingXS) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .symbolEffect(.bounce, value: isLiked)
                        Text("\(post.likesCount)")
                    }
                }
                .foregroundStyle(isLiked ? Theme.textPrimary : Theme.textSecondary)

                // Comment
                Button {
                    // Show comments
                } label: {
                    HStack(spacing: Theme.spacingXS) {
                        Image(systemName: "bubble.right")
                        Text("\(post.commentsCount)")
                    }
                }
                .foregroundStyle(Theme.textSecondary)

                Spacer()

                // Share
                Button {
                    // Share
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .foregroundStyle(Theme.textSecondary)
            }
            .font(Theme.subheadline)
        }
        .padding(Theme.spacingM)
        .glassBackground(cornerRadius: Theme.radiusL)
    }
}

// MARK: - Create Post Sheet

struct CreatePostSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var content = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: Theme.spacingM) {
                GlassTextEditor("What's on your mind?", text: $content)

                Spacer()
            }
            .padding()
            .background(Theme.background)
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Theme.textSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Post") {
                        // Create post
                        dismiss()
                    }
                    .foregroundStyle(Theme.textPrimary)
                    .disabled(content.isEmpty)
                }
            }
        }
    }
}

// MARK: - Matches View Full

struct MatchesViewFull: View {
    @State private var matches: [Match] = [.mock, .mockNew]
    @State private var selectedMatch: Match?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Theme.spacingL) {
                        // New matches section
                        if !newMatches.isEmpty {
                            newMatchesSection
                        }

                        // Conversations
                        if !conversations.isEmpty {
                            conversationsSection
                        }

                        if matches.isEmpty {
                            emptyState
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Matches")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var newMatches: [Match] {
        matches.filter { $0.isNew }
    }

    private var conversations: [Match] {
        matches.filter { $0.hasMessages }
    }

    private var newMatchesSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingM) {
            Text("New Matches")
                .font(Theme.headline)
                .foregroundStyle(Theme.textSecondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.spacingM) {
                    ForEach(newMatches) { match in
                        NewMatchCard(match: match)
                    }
                }
            }
        }
    }

    private var conversationsSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingM) {
            Text("Messages")
                .font(Theme.headline)
                .foregroundStyle(Theme.textSecondary)

            ForEach(conversations) { match in
                ConversationRow(match: match)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: Theme.spacingM) {
            Image(systemName: "heart.text.square")
                .font(.system(size: 60, weight: .light))
                .foregroundStyle(Theme.textTertiary)

            Text("No matches yet")
                .font(Theme.title3)
                .foregroundStyle(Theme.textSecondary)

            Text("Keep swiping to find your match!")
                .font(Theme.body)
                .foregroundStyle(Theme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.spacingXXL)
    }
}

// MARK: - New Match Card

struct NewMatchCard: View {
    let match: Match

    var body: some View {
        VStack(spacing: Theme.spacingS) {
            AsyncImage(url: match.otherUser?.primaryPhotoURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(Theme.surface)
            }
            .frame(width: 80, height: 80)
            .clipShape(Circle())
            .overlay {
                Circle()
                    .strokeBorder(Theme.border, lineWidth: 2)
            }

            Text(match.otherUser?.displayName ?? "")
                .font(Theme.subheadline)
                .foregroundStyle(Theme.textPrimary)
                .lineLimit(1)
        }
        .frame(width: 90)
    }
}

// MARK: - Conversation Row

struct ConversationRow: View {
    let match: Match

    var body: some View {
        HStack(spacing: Theme.spacingM) {
            AsyncImage(url: match.otherUser?.primaryPhotoURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(Theme.surface)
            }
            .frame(width: 60, height: 60)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                Text(match.otherUser?.displayName ?? "")
                    .font(Theme.headline)
                    .foregroundStyle(Theme.textPrimary)

                Text(match.lastMessage ?? "Start a conversation")
                    .font(Theme.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            if let date = match.lastMessageAt {
                Text(formatDate(date))
                    .font(Theme.caption)
                    .foregroundStyle(Theme.textTertiary)
            }
        }
        .padding(Theme.spacingM)
        .glassBackground(cornerRadius: Theme.radiusL)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Profile View Full

struct ProfileViewFull: View {
    @Environment(AuthService.self) private var authService
    @State private var showSettings = false
    @State private var showEditProfile = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Theme.spacingL) {
                        // Profile header
                        profileHeader

                        // Stats
                        statsSection

                        // Actions
                        actionsSection

                        // Settings link
                        settingsSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsSheet()
            }
            .sheet(isPresented: $showEditProfile) {
                Text("Edit Profile") // Placeholder
            }
        }
    }

    private var profileHeader: some View {
        VStack(spacing: Theme.spacingM) {
            // Photo
            AsyncImage(url: authService.currentUser?.primaryPhotoURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(Theme.surface)
                    .overlay {
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(Theme.textTertiary)
                    }
            }
            .frame(width: 120, height: 120)
            .clipShape(Circle())
            .overlay {
                Circle()
                    .strokeBorder(Theme.border, lineWidth: 2)
            }

            // Name
            VStack(spacing: Theme.spacingXS) {
                Text(authService.currentUser?.displayName ?? "Your Name")
                    .font(Theme.title2)
                    .foregroundStyle(Theme.textPrimary)

                if let user = authService.currentUser {
                    Text("\(user.age) • \(user.city ?? "Location")")
                        .font(Theme.body)
                        .foregroundStyle(Theme.textSecondary)
                }
            }

            // Edit button
            Button {
                showEditProfile = true
            } label: {
                HStack(spacing: Theme.spacingS) {
                    Image(systemName: "pencil")
                    Text("Edit Profile")
                }
            }
            .buttonStyle(.glass)
        }
    }

    private var statsSection: some View {
        HStack(spacing: Theme.spacingM) {
            statItem(value: "24", label: "Likes")
            statItem(value: "12", label: "Matches")
            statItem(value: "89%", label: "Complete")
        }
        .padding(Theme.spacingM)
        .glassBackground(cornerRadius: Theme.radiusL)
    }

    @ViewBuilder
    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: Theme.spacingXS) {
            Text(value)
                .font(Theme.title2)
                .foregroundStyle(Theme.textPrimary)
            Text(label)
                .font(Theme.caption)
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var actionsSection: some View {
        VStack(spacing: Theme.spacingS) {
            profileActionRow(icon: "photo.on.rectangle", title: "Manage Photos")
            profileActionRow(icon: "text.quote", title: "Edit Prompts")
            profileActionRow(icon: "heart.text.square", title: "Dating Preferences")
            profileActionRow(icon: "shield", title: "Verification")
        }
    }

    @ViewBuilder
    private func profileActionRow(icon: String, title: String) -> some View {
        Button {
            // Navigate
        } label: {
            HStack(spacing: Theme.spacingM) {
                Image(systemName: icon)
                    .font(.system(size: Theme.iconL))
                    .foregroundStyle(Theme.textSecondary)
                    .frame(width: 32)

                Text(title)
                    .font(Theme.body)
                    .foregroundStyle(Theme.textPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.textTertiary)
            }
            .padding(Theme.spacingM)
            .glassBackground(cornerRadius: Theme.radiusM)
        }
        .buttonStyle(.plain)
    }

    private var settingsSection: some View {
        Button {
            Task {
                try? await authService.signOut()
            }
        } label: {
            Text("Sign Out")
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(.top, Theme.spacingL)
    }
}

// MARK: - Settings Sheet

struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    settingsRow(icon: "envelope", title: "Email")
                    settingsRow(icon: "phone", title: "Phone")
                    settingsRow(icon: "lock", title: "Password")
                }

                Section("Notifications") {
                    settingsRow(icon: "bell", title: "Push Notifications")
                    settingsRow(icon: "envelope", title: "Email Notifications")
                }

                Section("Privacy") {
                    settingsRow(icon: "eye.slash", title: "Hidden Mode")
                    settingsRow(icon: "hand.raised", title: "Blocked Users")
                }

                Section("Support") {
                    settingsRow(icon: "questionmark.circle", title: "Help Center")
                    settingsRow(icon: "flag", title: "Report a Problem")
                }

                Section("Legal") {
                    settingsRow(icon: "doc.text", title: "Terms of Service")
                    settingsRow(icon: "shield", title: "Privacy Policy")
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(Theme.textPrimary)
                }
            }
        }
    }

    @ViewBuilder
    private func settingsRow(icon: String, title: String) -> some View {
        HStack(spacing: Theme.spacingM) {
            Image(systemName: icon)
                .foregroundStyle(Theme.textSecondary)
            Text(title)
                .foregroundStyle(Theme.textPrimary)
        }
        .listRowBackground(Theme.surface)
    }
}

// MARK: - Preview

#Preview {
    MainTabViewFull()
        .environment(AuthService())
}

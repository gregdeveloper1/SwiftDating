import SwiftUI

struct InterestsStepView: View {
    @Binding var selectedInterests: Set<String>

    private let allInterests: [InterestCategory] = [
        InterestCategory(name: "Music", interests: ["Rock", "Pop", "Hip-Hop", "Jazz", "Electronic", "Classical", "R&B", "Country", "Indie", "Metal"]),
        InterestCategory(name: "Sports", interests: ["Soccer", "Basketball", "Tennis", "Running", "Yoga", "Swimming", "Cycling", "Golf", "Hiking", "Gym"]),
        InterestCategory(name: "Food & Drink", interests: ["Coffee", "Wine", "Cooking", "Foodie", "Brunch", "Sushi", "Vegan", "Cocktails", "BBQ", "Baking"]),
        InterestCategory(name: "Entertainment", interests: ["Movies", "Netflix", "Gaming", "Reading", "Concerts", "Comedy", "Theater", "Podcasts", "Anime", "Board Games"]),
        InterestCategory(name: "Lifestyle", interests: ["Travel", "Photography", "Art", "Fashion", "Fitness", "Dogs", "Cats", "Volunteering", "Meditation", "Outdoors"]),
        InterestCategory(name: "Social", interests: ["Dancing", "Parties", "Karaoke", "Trivia", "Wine Tasting", "Book Club", "Networking", "Festivals", "Road Trips", "Beach"])
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacingL) {
                // Counter
                counterSection

                // Interests by category
                ForEach(allInterests) { category in
                    categorySection(category)
                }

                Spacer(minLength: 100)
            }
            .padding(.horizontal, Theme.spacingL)
            .padding(.top, Theme.spacingL)
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - Counter

    private var counterSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                Text("Select your interests")
                    .font(Theme.headline)
                    .foregroundStyle(Theme.textPrimary)

                Text("Choose at least 3 to help find better matches")
                    .font(Theme.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            }

            Spacer()

            Text("\(selectedInterests.count)")
                .font(Theme.title2)
                .foregroundStyle(selectedInterests.count >= 3 ? Theme.textPrimary : Theme.textTertiary)
                .padding(.horizontal, Theme.spacingM)
                .padding(.vertical, Theme.spacingS)
                .glassBackground(cornerRadius: Theme.radiusM)
        }
    }

    // MARK: - Category Section

    @ViewBuilder
    private func categorySection(_ category: InterestCategory) -> some View {
        VStack(alignment: .leading, spacing: Theme.spacingS) {
            Text(category.name)
                .font(Theme.headline)
                .foregroundStyle(Theme.textSecondary)

            FlowLayout(spacing: Theme.spacingS) {
                ForEach(category.interests, id: \.self) { interest in
                    interestTag(interest)
                }
            }
        }
    }

    @ViewBuilder
    private func interestTag(_ interest: String) -> some View {
        let isSelected = selectedInterests.contains(interest)

        Button {
            Haptics.selection()
            withAnimation(.easeInOut(duration: 0.2)) {
                if isSelected {
                    selectedInterests.remove(interest)
                } else if selectedInterests.count < Constants.maxInterests {
                    selectedInterests.insert(interest)
                }
            }
        } label: {
            Text(interest)
                .font(Theme.subheadline)
                .foregroundStyle(isSelected ? .black : Theme.textSecondary)
                .padding(.horizontal, Theme.spacingM)
                .padding(.vertical, Theme.spacingS)
                .background(
                    isSelected ? Color.white : Theme.surface,
                    in: Capsule()
                )
                .overlay {
                    Capsule()
                        .strokeBorder(
                            isSelected ? Color.clear : Theme.borderLight,
                            lineWidth: 0.5
                        )
                }
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.05 : 1.0)
    }
}

// MARK: - Interest Category

struct InterestCategory: Identifiable {
    let id = UUID()
    let name: String
    let interests: [String]
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )

        for (index, subview) in subviews.enumerated() {
            subview.place(
                at: CGPoint(
                    x: bounds.minX + result.positions[index].x,
                    y: bounds.minY + result.positions[index].y
                ),
                proposal: .unspecified
            )
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth, x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(
                width: maxWidth,
                height: y + rowHeight
            )
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Theme.background.ignoresSafeArea()
        InterestsStepView(selectedInterests: .constant(["Coffee", "Travel", "Yoga"]))
    }
}

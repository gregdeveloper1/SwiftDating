import SwiftUI

struct BasicInfoStepView: View {
    @Binding var displayName: String
    @Binding var birthDate: Date
    @Binding var gender: Gender
    @Binding var genderPreference: Set<Gender>

    private let minDate = Calendar.current.date(byAdding: .year, value: -100, to: Date())!
    private let maxDate = Calendar.current.date(byAdding: .year, value: -18, to: Date())!

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacingXL) {
                // Name
                nameSection

                // Birthday
                birthdaySection

                // Gender
                genderSection

                // Preference
                preferenceSection

                Spacer(minLength: 100)
            }
            .padding(.horizontal, Theme.spacingL)
            .padding(.top, Theme.spacingL)
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - Name Section

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingS) {
            sectionLabel("First Name")

            GlassTextField(
                "Your first name",
                text: $displayName,
                textContentType: .givenName,
                autocapitalization: .words
            )

            Text("This is how you'll appear to others")
                .font(Theme.caption)
                .foregroundStyle(Theme.textTertiary)
        }
    }

    // MARK: - Birthday Section

    private var birthdaySection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingS) {
            sectionLabel("Birthday")

            DatePicker(
                "",
                selection: $birthDate,
                in: minDate...maxDate,
                displayedComponents: .date
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .colorScheme(.dark)
            .frame(maxWidth: .infinity)
            .glassCard(padding: Theme.spacingS)

            Text("You must be 18+ to use NativeDating")
                .font(Theme.caption)
                .foregroundStyle(Theme.textTertiary)
        }
    }

    // MARK: - Gender Section

    private var genderSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingS) {
            sectionLabel("I am a")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.spacingS) {
                ForEach(Gender.allCases) { genderOption in
                    genderButton(genderOption, isSelected: gender == genderOption) {
                        Haptics.selection()
                        gender = genderOption
                    }
                }
            }
        }
    }

    // MARK: - Preference Section

    private var preferenceSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingS) {
            sectionLabel("Show me")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.spacingS) {
                ForEach(Gender.allCases) { genderOption in
                    genderButton(genderOption, isSelected: genderPreference.contains(genderOption)) {
                        Haptics.selection()
                        if genderPreference.contains(genderOption) {
                            genderPreference.remove(genderOption)
                        } else {
                            genderPreference.insert(genderOption)
                        }
                    }
                }
            }

            Text("Select all that apply")
                .font(Theme.caption)
                .foregroundStyle(Theme.textTertiary)
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(Theme.headline)
            .foregroundStyle(Theme.textPrimary)
    }

    @ViewBuilder
    private func genderButton(_ genderOption: Gender, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: Theme.spacingS) {
                Image(systemName: genderOption.icon)
                Text(genderOption.displayName)
            }
            .font(Theme.body)
            .foregroundStyle(isSelected ? Theme.textPrimary : Theme.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.spacingM)
            .background(
                isSelected ? Theme.surfaceActive : Theme.surface,
                in: RoundedRectangle(cornerRadius: Theme.radiusM)
            )
            .overlay {
                RoundedRectangle(cornerRadius: Theme.radiusM)
                    .strokeBorder(
                        isSelected ? Theme.border : Theme.borderLight,
                        lineWidth: isSelected ? 1 : 0.5
                    )
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Theme.background.ignoresSafeArea()
        BasicInfoStepView(
            displayName: .constant(""),
            birthDate: .constant(Date()),
            gender: .constant(.man),
            genderPreference: .constant([])
        )
    }
}

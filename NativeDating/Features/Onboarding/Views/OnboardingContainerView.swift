import SwiftUI

struct OnboardingContainerView: View {
    @Environment(AuthService.self) private var authService

    @State private var currentStep: OnboardingStep = .basicInfo
    @State private var displayName = ""
    @State private var birthDate = Calendar.current.date(byAdding: .year, value: -25, to: Date())!
    @State private var gender: Gender = .man
    @State private var genderPreference: Set<Gender> = []
    @State private var photos: [PhotoItem] = []
    @State private var interests: Set<String> = []
    @State private var prompts: [PromptAnswer] = []
    @State private var isLoading = false

    enum OnboardingStep: Int, CaseIterable {
        case basicInfo
        case photos
        case interests
        case prompts

        var title: String {
            switch self {
            case .basicInfo: return "About You"
            case .photos: return "Add Photos"
            case .interests: return "Your Interests"
            case .prompts: return "Share More"
            }
        }

        var subtitle: String {
            switch self {
            case .basicInfo: return "Let's start with the basics"
            case .photos: return "Add at least 2 photos"
            case .interests: return "Select what you're into"
            case .prompts: return "Help others get to know you"
            }
        }
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress bar
                progressBar
                    .padding(.horizontal, Theme.spacingL)
                    .padding(.top, Theme.spacingM)

                // Step content
                TabView(selection: $currentStep) {
                    BasicInfoStepView(
                        displayName: $displayName,
                        birthDate: $birthDate,
                        gender: $gender,
                        genderPreference: $genderPreference
                    )
                    .tag(OnboardingStep.basicInfo)

                    PhotosStepView(photos: $photos)
                        .tag(OnboardingStep.photos)

                    InterestsStepView(selectedInterests: $interests)
                        .tag(OnboardingStep.interests)

                    PromptsStepView(prompts: $prompts)
                        .tag(OnboardingStep.prompts)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)

                // Navigation buttons
                navigationButtons
                    .padding(.horizontal, Theme.spacingL)
                    .padding(.bottom, Theme.spacingL)
            }
        }
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        VStack(alignment: .leading, spacing: Theme.spacingS) {
            HStack {
                Text(currentStep.title)
                    .font(Theme.headline)
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Text("\(currentStep.rawValue + 1)/\(OnboardingStep.allCases.count)")
                    .font(Theme.caption)
                    .foregroundStyle(Theme.textTertiary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Theme.surface)
                        .frame(height: 4)

                    Capsule()
                        .fill(Color.white)
                        .frame(
                            width: geometry.size.width * progress,
                            height: 4
                        )
                        .animation(.easeInOut, value: currentStep)
                }
            }
            .frame(height: 4)

            Text(currentStep.subtitle)
                .font(Theme.subheadline)
                .foregroundStyle(Theme.textSecondary)
        }
    }

    private var progress: CGFloat {
        CGFloat(currentStep.rawValue + 1) / CGFloat(OnboardingStep.allCases.count)
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        HStack(spacing: Theme.spacingM) {
            // Back button
            if currentStep != .basicInfo {
                Button {
                    goBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: Theme.iconM, weight: .semibold))
                }
                .buttonStyle(.outlineGlass)
            }

            // Next/Complete button
            Button {
                if currentStep == OnboardingStep.allCases.last {
                    completeOnboarding()
                } else {
                    goNext()
                }
            } label: {
                HStack(spacing: Theme.spacingS) {
                    if isLoading {
                        ProgressView()
                            .tint(.black)
                    } else {
                        Text(currentStep == OnboardingStep.allCases.last ? "Complete" : "Continue")
                        Image(systemName: currentStep == OnboardingStep.allCases.last ? "checkmark" : "chevron.right")
                    }
                }
            }
            .buttonStyle(.solidGlassFullWidth)
            .disabled(!canProceed || isLoading)
            .opacity(canProceed ? 1 : 0.6)
        }
    }

    // MARK: - Validation

    private var canProceed: Bool {
        switch currentStep {
        case .basicInfo:
            return !displayName.isEmpty && !genderPreference.isEmpty && isValidAge
        case .photos:
            return photos.count >= Constants.minPhotos
        case .interests:
            return interests.count >= 3
        case .prompts:
            return prompts.count >= 1
        }
    }

    private var isValidAge: Bool {
        let age = Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
        return age >= Constants.minAge
    }

    // MARK: - Actions

    private func goBack() {
        Haptics.buttonTap()
        if let previous = OnboardingStep(rawValue: currentStep.rawValue - 1) {
            withAnimation {
                currentStep = previous
            }
        }
    }

    private func goNext() {
        Haptics.buttonTap()
        if let next = OnboardingStep(rawValue: currentStep.rawValue + 1) {
            withAnimation {
                currentStep = next
            }
        }
    }

    private func completeOnboarding() {
        Haptics.buttonTap()
        isLoading = true

        Task {
            do {
                // Create user profile
                try await authService.createUserProfile(
                    displayName: displayName,
                    birthDate: birthDate,
                    gender: gender
                )
                // TODO: Upload photos and update profile with interests/prompts
                Haptics.success()
            } catch {
                Haptics.error()
                print("Onboarding failed: \(error)")
            }
            isLoading = false
        }
    }
}

// MARK: - Photo Item

struct PhotoItem: Identifiable, Equatable {
    let id = UUID()
    var image: UIImage?
    var url: String?
}

// MARK: - Preview

#Preview {
    OnboardingContainerView()
        .environment(AuthService())
}

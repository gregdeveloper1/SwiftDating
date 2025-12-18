import SwiftUI

struct WelcomeView: View {
    @State private var showLogin = false
    @State private var showSignUp = false
    @State private var animateBackground = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Animated background
                backgroundView(size: geometry.size)

                // Content
                VStack(spacing: 0) {
                    Spacer()

                    // Logo and tagline
                    logoSection

                    Spacer()

                    // Action buttons
                    buttonSection

                    // Terms
                    termsSection
                        .padding(.bottom, Theme.spacingXL)
                }
                .padding(.horizontal, Theme.spacingL)
            }
        }
        .background(Theme.background)
        .sheet(isPresented: $showLogin) {
            LoginView()
        }
        .sheet(isPresented: $showSignUp) {
            SignUpView()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animateBackground = true
            }
        }
    }

    // MARK: - Background

    @ViewBuilder
    private func backgroundView(size: CGSize) -> some View {
        ZStack {
            // Gradient orbs
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.1), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: size.width * 0.6
                    )
                )
                .frame(width: size.width * 1.2)
                .offset(
                    x: animateBackground ? size.width * 0.2 : -size.width * 0.2,
                    y: -size.height * 0.3
                )
                .blur(radius: 60)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.08), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: size.width * 0.5
                    )
                )
                .frame(width: size.width)
                .offset(
                    x: animateBackground ? -size.width * 0.3 : size.width * 0.1,
                    y: size.height * 0.2
                )
                .blur(radius: 50)
        }
    }

    // MARK: - Logo Section

    private var logoSection: some View {
        VStack(spacing: Theme.spacingL) {
            // App icon/logo
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 120, height: 120)

                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [.white.opacity(0.4), .white.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .frame(width: 120, height: 120)

                Image(systemName: "heart.fill")
                    .font(.system(size: 50, weight: .medium))
                    .foregroundStyle(Theme.textPrimary)
            }
            .shadow(color: Theme.shadowMedium, radius: 30, x: 0, y: 15)

            VStack(spacing: Theme.spacingS) {
                Text("NativeDating")
                    .font(Theme.largeTitle)
                    .foregroundStyle(Theme.textPrimary)

                Text("Connect authentically")
                    .font(Theme.title3)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
    }

    // MARK: - Button Section

    private var buttonSection: some View {
        VStack(spacing: Theme.spacingM) {
            // Sign Up button (primary)
            Button {
                Haptics.buttonTap()
                showSignUp = true
            } label: {
                HStack(spacing: Theme.spacingS) {
                    Image(systemName: "person.badge.plus")
                    Text("Create Account")
                }
            }
            .buttonStyle(.solidGlassFullWidth)

            // Sign In button (secondary)
            Button {
                Haptics.buttonTap()
                showLogin = true
            } label: {
                HStack(spacing: Theme.spacingS) {
                    Image(systemName: "arrow.right.circle")
                    Text("Sign In")
                }
            }
            .buttonStyle(.glassFullWidth)

            // Divider
            HStack(spacing: Theme.spacingM) {
                Rectangle()
                    .fill(Theme.borderLight)
                    .frame(height: 0.5)
                Text("or")
                    .font(Theme.caption)
                    .foregroundStyle(Theme.textTertiary)
                Rectangle()
                    .fill(Theme.borderLight)
                    .frame(height: 0.5)
            }
            .padding(.vertical, Theme.spacingS)

            // Sign in with Apple
            SignInWithAppleButton()
        }
    }

    // MARK: - Terms Section

    private var termsSection: some View {
        VStack(spacing: Theme.spacingXS) {
            Text("By continuing, you agree to our")
                .font(Theme.caption)
                .foregroundStyle(Theme.textTertiary)

            HStack(spacing: Theme.spacingXS) {
                Button("Terms of Service") {
                    // Open terms
                }
                .font(Theme.caption.weight(.medium))
                .foregroundStyle(Theme.textSecondary)

                Text("and")
                    .font(Theme.caption)
                    .foregroundStyle(Theme.textTertiary)

                Button("Privacy Policy") {
                    // Open privacy
                }
                .font(Theme.caption.weight(.medium))
                .foregroundStyle(Theme.textSecondary)
            }
        }
        .padding(.top, Theme.spacingL)
    }
}

// MARK: - Sign In with Apple Button

struct SignInWithAppleButton: View {
    @Environment(AuthService.self) private var authService
    @State private var coordinator = AppleSignInCoordinator()
    @State private var isLoading = false

    var body: some View {
        Button {
            Task {
                await signInWithApple()
            }
        } label: {
            HStack(spacing: Theme.spacingS) {
                if isLoading {
                    ProgressView()
                        .tint(Theme.textPrimary)
                } else {
                    Image(systemName: "apple.logo")
                    Text("Continue with Apple")
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.spacingM)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay {
                Capsule()
                    .strokeBorder(Theme.borderLight, lineWidth: 0.5)
            }
        }
        .buttonStyle(.plain)
        .foregroundStyle(Theme.textPrimary)
        .disabled(isLoading)
    }

    private func signInWithApple() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let credential = try await coordinator.signIn()
            try await authService.signInWithApple(credential: credential)
            Haptics.success()
        } catch {
            Haptics.error()
            print("Apple Sign In failed: \(error)")
        }
    }
}

// MARK: - Preview

#Preview {
    WelcomeView()
        .environment(AuthService())
}

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthService.self) private var authService

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var passwordStrength: PasswordStrength = .weak

    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case email, password, confirmPassword
    }

    private var isFormValid: Bool {
        !email.isEmpty &&
        email.contains("@") &&
        password.count >= 8 &&
        password == confirmPassword
    }

    private var passwordsMatch: Bool {
        !confirmPassword.isEmpty && password == confirmPassword
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.spacingXL) {
                    // Header
                    headerSection

                    // Form
                    formSection

                    // Password strength
                    passwordStrengthSection

                    // Sign up button
                    signUpButton

                    Spacer(minLength: Theme.spacingXL)
                }
                .padding(.horizontal, Theme.spacingL)
                .padding(.top, Theme.spacingXL)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Theme.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: Theme.iconM, weight: .medium))
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
            }
            .alert("Sign Up Failed", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .onChange(of: password) { _, newValue in
                passwordStrength = PasswordStrength.evaluate(newValue)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: Theme.spacingM) {
            Image(systemName: "person.badge.plus")
                .font(.system(size: 60, weight: .light))
                .foregroundStyle(Theme.textSecondary)

            VStack(spacing: Theme.spacingS) {
                Text("Create Account")
                    .font(Theme.title)
                    .foregroundStyle(Theme.textPrimary)

                Text("Start your journey")
                    .font(Theme.body)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
    }

    // MARK: - Form

    private var formSection: some View {
        VStack(spacing: Theme.spacingM) {
            GlassTextField(
                "Email",
                text: $email,
                icon: "envelope",
                keyboardType: .emailAddress,
                textContentType: .emailAddress,
                autocapitalization: .never,
                submitLabel: .next
            ) {
                focusedField = .password
            }
            .focused($focusedField, equals: .email)

            GlassTextField(
                "Password",
                text: $password,
                icon: "lock",
                isSecure: true,
                textContentType: .newPassword,
                submitLabel: .next
            ) {
                focusedField = .confirmPassword
            }
            .focused($focusedField, equals: .password)

            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                GlassTextField(
                    "Confirm Password",
                    text: $confirmPassword,
                    icon: "lock.fill",
                    isSecure: true,
                    textContentType: .newPassword,
                    submitLabel: .go
                ) {
                    signUp()
                }
                .focused($focusedField, equals: .confirmPassword)

                // Password match indicator
                if !confirmPassword.isEmpty {
                    HStack(spacing: Theme.spacingXS) {
                        Image(systemName: passwordsMatch ? "checkmark.circle.fill" : "xmark.circle.fill")
                        Text(passwordsMatch ? "Passwords match" : "Passwords don't match")
                    }
                    .font(Theme.caption)
                    .foregroundStyle(passwordsMatch ? Theme.textSecondary : Theme.textPrimary)
                    .padding(.leading, Theme.spacingXS)
                }
            }
        }
    }

    // MARK: - Password Strength

    private var passwordStrengthSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingS) {
            // Strength bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Theme.surface)
                        .frame(height: 4)

                    Capsule()
                        .fill(passwordStrength.color)
                        .frame(width: geometry.size.width * passwordStrength.progress, height: 4)
                        .animation(.easeInOut, value: passwordStrength)
                }
            }
            .frame(height: 4)

            // Strength label
            HStack {
                Text("Password strength:")
                    .foregroundStyle(Theme.textTertiary)
                Text(passwordStrength.label)
                    .foregroundStyle(passwordStrength.color)
            }
            .font(Theme.caption)

            // Requirements
            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                requirementRow("At least 8 characters", met: password.count >= 8)
                requirementRow("Contains a number", met: password.contains(where: \.isNumber))
                requirementRow("Contains uppercase", met: password.contains(where: \.isUppercase))
            }
        }
        .padding(Theme.spacingM)
        .glassBackground(cornerRadius: Theme.radiusM)
    }

    @ViewBuilder
    private func requirementRow(_ text: String, met: Bool) -> some View {
        HStack(spacing: Theme.spacingS) {
            Image(systemName: met ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 14))
                .foregroundStyle(met ? Theme.textSecondary : Theme.textDisabled)
            Text(text)
                .font(Theme.caption)
                .foregroundStyle(met ? Theme.textSecondary : Theme.textDisabled)
        }
    }

    // MARK: - Sign Up Button

    private var signUpButton: some View {
        Button {
            signUp()
        } label: {
            HStack(spacing: Theme.spacingS) {
                if authService.isLoading {
                    ProgressView()
                        .tint(.black)
                } else {
                    Text("Create Account")
                    Image(systemName: "arrow.right")
                }
            }
        }
        .buttonStyle(.solidGlassFullWidth)
        .disabled(!isFormValid || authService.isLoading)
        .opacity(isFormValid ? 1 : 0.6)
    }

    // MARK: - Actions

    private func signUp() {
        guard isFormValid else { return }

        focusedField = nil
        Haptics.buttonTap()

        Task {
            do {
                try await authService.signUp(email: email, password: password)
                Haptics.success()
                dismiss()
            } catch {
                Haptics.error()
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

// MARK: - Password Strength

enum PasswordStrength {
    case weak
    case fair
    case good
    case strong

    var label: String {
        switch self {
        case .weak: return "Weak"
        case .fair: return "Fair"
        case .good: return "Good"
        case .strong: return "Strong"
        }
    }

    var color: Color {
        switch self {
        case .weak: return .white.opacity(0.3)
        case .fair: return .white.opacity(0.5)
        case .good: return .white.opacity(0.7)
        case .strong: return .white
        }
    }

    var progress: CGFloat {
        switch self {
        case .weak: return 0.25
        case .fair: return 0.5
        case .good: return 0.75
        case .strong: return 1.0
        }
    }

    static func evaluate(_ password: String) -> PasswordStrength {
        var score = 0

        if password.count >= 8 { score += 1 }
        if password.count >= 12 { score += 1 }
        if password.contains(where: \.isNumber) { score += 1 }
        if password.contains(where: \.isUppercase) { score += 1 }
        if password.contains(where: \.isLowercase) { score += 1 }
        if password.contains(where: { "!@#$%^&*()_+-=[]{}|;':\",./<>?".contains($0) }) { score += 1 }

        switch score {
        case 0...2: return .weak
        case 3: return .fair
        case 4...5: return .good
        default: return .strong
        }
    }
}

// MARK: - Preview

#Preview {
    SignUpView()
        .environment(AuthService())
}

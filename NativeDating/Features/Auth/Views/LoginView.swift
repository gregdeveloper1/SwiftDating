import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthService.self) private var authService

    @State private var email = ""
    @State private var password = ""
    @State private var showForgotPassword = false
    @State private var showError = false
    @State private var errorMessage = ""

    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case email, password
    }

    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && email.contains("@")
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.spacingXL) {
                    // Header
                    headerSection

                    // Form
                    formSection

                    // Forgot password
                    forgotPasswordButton

                    // Sign in button
                    signInButton

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
            .alert("Sign In Failed", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .sheet(isPresented: $showForgotPassword) {
                ForgotPasswordView()
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: Theme.spacingM) {
            Image(systemName: "person.circle")
                .font(.system(size: 60, weight: .light))
                .foregroundStyle(Theme.textSecondary)

            VStack(spacing: Theme.spacingS) {
                Text("Welcome Back")
                    .font(Theme.title)
                    .foregroundStyle(Theme.textPrimary)

                Text("Sign in to continue")
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
                textContentType: .password,
                submitLabel: .go
            ) {
                signIn()
            }
            .focused($focusedField, equals: .password)
        }
    }

    // MARK: - Forgot Password

    private var forgotPasswordButton: some View {
        HStack {
            Spacer()
            Button {
                showForgotPassword = true
            } label: {
                Text("Forgot Password?")
                    .font(Theme.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
    }

    // MARK: - Sign In Button

    private var signInButton: some View {
        Button {
            signIn()
        } label: {
            HStack(spacing: Theme.spacingS) {
                if authService.isLoading {
                    ProgressView()
                        .tint(.black)
                } else {
                    Text("Sign In")
                    Image(systemName: "arrow.right")
                }
            }
        }
        .buttonStyle(.solidGlassFullWidth)
        .disabled(!isFormValid || authService.isLoading)
        .opacity(isFormValid ? 1 : 0.6)
    }

    // MARK: - Actions

    private func signIn() {
        guard isFormValid else { return }

        focusedField = nil
        Haptics.buttonTap()

        Task {
            do {
                try await authService.signIn(email: email, password: password)
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

// MARK: - Forgot Password View

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthService.self) private var authService

    @State private var email = ""
    @State private var showSuccess = false
    @State private var showError = false
    @State private var errorMessage = ""

    private var isEmailValid: Bool {
        !email.isEmpty && email.contains("@")
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: Theme.spacingXL) {
                // Icon
                Image(systemName: "key.fill")
                    .font(.system(size: 50, weight: .light))
                    .foregroundStyle(Theme.textSecondary)
                    .padding(.top, Theme.spacingXL)

                // Text
                VStack(spacing: Theme.spacingS) {
                    Text("Reset Password")
                        .font(Theme.title)
                        .foregroundStyle(Theme.textPrimary)

                    Text("Enter your email and we'll send you a link to reset your password.")
                        .font(Theme.body)
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                }

                // Email field
                GlassTextField(
                    "Email",
                    text: $email,
                    icon: "envelope",
                    keyboardType: .emailAddress,
                    textContentType: .emailAddress,
                    autocapitalization: .never
                )

                // Send button
                Button {
                    resetPassword()
                } label: {
                    HStack {
                        if authService.isLoading {
                            ProgressView()
                                .tint(.black)
                        } else {
                            Text("Send Reset Link")
                        }
                    }
                }
                .buttonStyle(.solidGlassFullWidth)
                .disabled(!isEmailValid || authService.isLoading)
                .opacity(isEmailValid ? 1 : 0.6)

                Spacer()
            }
            .padding(.horizontal, Theme.spacingL)
            .background(Theme.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
            }
            .alert("Check Your Email", isPresented: $showSuccess) {
                Button("OK") { dismiss() }
            } message: {
                Text("We've sent a password reset link to \(email)")
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func resetPassword() {
        Haptics.buttonTap()

        Task {
            do {
                try await authService.resetPassword(email: email)
                Haptics.success()
                showSuccess = true
            } catch {
                Haptics.error()
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

// MARK: - Preview

#Preview {
    LoginView()
        .environment(AuthService())
}

import Foundation
import Supabase
import AuthenticationServices

/// Service handling all authentication operations
@Observable
final class AuthService {
    // MARK: - Properties

    private let supabase = SupabaseManager.shared

    var currentUser: User?
    var session: Session?
    var isLoading = false
    var error: AuthError?

    // MARK: - Computed Properties

    var isAuthenticated: Bool {
        session != nil
    }

    var needsOnboarding: Bool {
        guard let user = currentUser else { return true }
        return user.photoURLs.isEmpty || user.displayName.isEmpty
    }

    var currentUserId: UUID? {
        session?.user.id
    }

    // MARK: - Auth State Observation

    func observeAuthState() async {
        for await (event, session) in supabase.auth.authStateChanges {
            await MainActor.run {
                self.session = session

                switch event {
                case .initialSession, .signedIn:
                    if let userId = session?.user.id {
                        Task {
                            await self.fetchCurrentUser(id: userId)
                        }
                    }
                case .signedOut:
                    self.currentUser = nil
                case .userUpdated:
                    if let userId = session?.user.id {
                        Task {
                            await self.fetchCurrentUser(id: userId)
                        }
                    }
                default:
                    break
                }
            }
        }
    }

    // MARK: - Sign Up

    func signUp(email: String, password: String) async throws {
        isLoading = true
        error = nil

        defer { isLoading = false }

        do {
            let response = try await supabase.auth.signUp(
                email: email,
                password: password
            )

            if let session = response.session {
                self.session = session
            }
        } catch {
            self.error = .signUpFailed(error.localizedDescription)
            throw self.error!
        }
    }

    // MARK: - Sign In

    func signIn(email: String, password: String) async throws {
        isLoading = true
        error = nil

        defer { isLoading = false }

        do {
            let session = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            self.session = session
        } catch {
            self.error = .signInFailed(error.localizedDescription)
            throw self.error!
        }
    }

    // MARK: - Sign In with Apple

    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async throws {
        isLoading = true
        error = nil

        defer { isLoading = false }

        guard let identityToken = credential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8) else {
            self.error = .invalidAppleCredential
            throw self.error!
        }

        do {
            let session = try await supabase.auth.signInWithIdToken(
                credentials: .init(
                    provider: .apple,
                    idToken: tokenString
                )
            )
            self.session = session

            // If this is a new user, we may need to create their profile
            if let userId = session.user.id {
                await fetchCurrentUser(id: userId)
            }
        } catch {
            self.error = .signInFailed(error.localizedDescription)
            throw self.error!
        }
    }

    // MARK: - Sign Out

    func signOut() async throws {
        isLoading = true
        error = nil

        defer { isLoading = false }

        do {
            try await supabase.auth.signOut()
            self.session = nil
            self.currentUser = nil
        } catch {
            self.error = .signOutFailed(error.localizedDescription)
            throw self.error!
        }
    }

    // MARK: - Password Reset

    func resetPassword(email: String) async throws {
        isLoading = true
        error = nil

        defer { isLoading = false }

        do {
            try await supabase.auth.resetPasswordForEmail(email)
        } catch {
            self.error = .passwordResetFailed(error.localizedDescription)
            throw self.error!
        }
    }

    // MARK: - Fetch Current User

    private func fetchCurrentUser(id: UUID) async {
        do {
            let user: User = try await supabase
                .from(SupabaseConfig.Tables.users)
                .select()
                .eq("id", value: id.uuidString)
                .single()
                .execute()
                .value

            await MainActor.run {
                self.currentUser = user
            }
        } catch {
            // User might not exist yet (new signup)
            print("User not found, may need onboarding: \(error)")
        }
    }

    // MARK: - Create User Profile

    func createUserProfile(
        displayName: String,
        birthDate: Date,
        gender: Gender
    ) async throws {
        guard let userId = currentUserId,
              let email = session?.user.email else {
            throw AuthError.notAuthenticated
        }

        let newUser = User.new(
            id: userId,
            email: email,
            displayName: displayName,
            birthDate: birthDate,
            gender: gender
        )

        do {
            try await supabase
                .from(SupabaseConfig.Tables.users)
                .insert(newUser)
                .execute()

            await MainActor.run {
                self.currentUser = newUser
            }
        } catch {
            throw AuthError.profileCreationFailed(error.localizedDescription)
        }
    }
}

// MARK: - Auth Error

enum AuthError: LocalizedError {
    case signUpFailed(String)
    case signInFailed(String)
    case signOutFailed(String)
    case passwordResetFailed(String)
    case invalidAppleCredential
    case notAuthenticated
    case profileCreationFailed(String)

    var errorDescription: String? {
        switch self {
        case .signUpFailed(let message):
            return "Sign up failed: \(message)"
        case .signInFailed(let message):
            return "Sign in failed: \(message)"
        case .signOutFailed(let message):
            return "Sign out failed: \(message)"
        case .passwordResetFailed(let message):
            return "Password reset failed: \(message)"
        case .invalidAppleCredential:
            return "Invalid Apple credentials"
        case .notAuthenticated:
            return "Not authenticated"
        case .profileCreationFailed(let message):
            return "Profile creation failed: \(message)"
        }
    }
}

// MARK: - Apple Sign In Coordinator

@MainActor
final class AppleSignInCoordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private var continuation: CheckedContinuation<ASAuthorizationAppleIDCredential, Error>?

    func signIn() async throws -> ASAuthorizationAppleIDCredential {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation

            let provider = ASAuthorizationAppleIDProvider()
            let request = provider.createRequest()
            request.requestedScopes = [.fullName, .email]

            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("No window available")
        }
        return window
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            continuation?.resume(returning: credential)
        }
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        continuation?.resume(throwing: error)
    }
}

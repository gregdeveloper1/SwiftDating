import SwiftUI

struct ContentView: View {
    @Environment(AuthService.self) private var authService

    var body: some View {
        Group {
            if authService.isAuthenticated {
                if authService.needsOnboarding {
                    OnboardingContainerView()
                } else {
                    MainTabView()
                }
            } else {
                WelcomeView()
            }
        }
        .background(Theme.background)
        .task {
            await authService.observeAuthState()
        }
    }
}

#Preview {
    ContentView()
        .environment(AuthService())
}

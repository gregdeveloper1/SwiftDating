import SwiftUI

@main
struct NativeDatingApp: App {
    @State private var authService = AuthService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authService)
                .preferredColorScheme(.dark)
        }
    }
}

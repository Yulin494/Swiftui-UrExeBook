import SwiftUI

class AppState: ObservableObject {
    @Published var hasSeenOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasSeenOnboarding, forKey: "hasSeenOnboarding")
        }
    }

    init() {
        self.hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    }
}

@main
struct MyApp: App {
    @StateObject private var appState = AppState() // 使用 StateObject 管理 App 內部狀態

    var body: some Scene {
        WindowGroup {
            if appState.hasSeenOnboarding {
                ContentView()
                    .environmentObject(appState) // 傳遞 App 狀態
            } else {
                OnboardingView()
                    .environmentObject(appState)
            }
        }
    }
}

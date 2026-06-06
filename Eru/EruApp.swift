import SwiftUI
import SwiftData

@main
struct EruApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: PracticeSession.self)

        Settings {
            SettingsView()
        }
    }
}

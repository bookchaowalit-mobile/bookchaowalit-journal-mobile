import SwiftUI
import MindSpaceCore

@main
struct MindSpaceApp: App {
    @StateObject private var journalStore = JournalStore()
    @StateObject private var meditationTimer = MeditationTimer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(journalStore)
                .environmentObject(meditationTimer)
                .preferredColorScheme(.dark)
        }
    }
}

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            MeditationView()
                .tabItem { Label("Breathe", systemImage: "wind") }
                .tag(0)

            JournalView()
                .tabItem { Label("Journal", systemImage: "book.closed") }
                .tag(1)

            StatsView()
                .tabItem { Label("Stats", systemImage: "chart.bar") }
                .tag(2)
        }
        .tint(Color(hex: "7C3AED"))
    }
}

// MARK: - Colors
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }
}

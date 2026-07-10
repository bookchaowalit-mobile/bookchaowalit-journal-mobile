import SwiftUI
import Combine

// MARK: - Journal Models
struct JournalEntry: Identifiable, Codable {
    let id: UUID
    var title: String
    var content: String
    var mood: Mood
    var date: Date
    var tags: [String]

    init(id: UUID = UUID(), title: String, content: String, mood: Mood, date: Date = Date(), tags: [String] = []) {
        self.id = id; self.title = title; self.content = content; self.mood = mood; self.date = date; self.tags = tags
    }
}

enum Mood: String, Codable, CaseIterable {
    case great = "Great", good = "Good", okay = "Okay", low = "Low", bad = "Bad"
    var emoji: String {
        switch self { case .great: return "😊"; case .good: return "🙂"; case .okay: return "😐"; case .low: return "😔"; case .bad: return "😢" }
    }
    var color: Color {
        switch self { case .great: return .green; case .good: return .mint; case .okay: return .yellow; case .low: return .orange; case .bad: return .red }
    }
}

// MARK: - Journal Store
class JournalStore: ObservableObject {
    @Published var entries: [JournalEntry] = []

    private let key = "mindspace_journal"

    init() { load() }

    func addEntry(title: String, content: String, mood: Mood, tags: [String] = []) {
        entries.insert(JournalEntry(title: title, content: content, mood: mood, tags: tags), at: 0)
        save()
    }

    func deleteEntry(_ id: UUID) {
        entries.removeAll { $0.id == id }
        save()
    }

    var moodCounts: [Mood: Int] {
        Dictionary(entries.map { ($0.mood, 1) }, uniquingKeysWith: +)
    }

    var streakDays: Int {
        let cal = Calendar.current
        let dates = Set(entries.map { cal.startOfDay(for: $0.date) })
        var streak = 0
        var day = cal.startOfDay(for: Date())
        while dates.contains(day) { streak += 1; day = cal.date(byAdding: .day, value: -1, to: day)! }
        return streak
    }

    private func save() {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([JournalEntry].self, from: data) {
            entries = decoded
        }
    }
}

// MARK: - Meditation Timer
class MeditationTimer: ObservableObject {
    @Published var isRunning = false
    @Published var secondsRemaining: Int = 300
    @Published var totalMinutes: Int = 0
    @Published var sessionsCompleted: Int = 0
    @Published var selectedDuration: Int = 5

    private var timer: AnyCancellable?
    private let durations = [1, 3, 5, 10, 15, 20, 30]

    let availableDurations: [Int] { durations }

    func start() {
        secondsRemaining = selectedDuration * 60
        isRunning = true
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { _ in
            if self.secondsRemaining > 0 {
                self.secondsRemaining -= 1
            } else {
                self.complete()
            }
        }
    }

    func pause() {
        isRunning = false
        timer?.cancel()
    }

    func reset() {
        timer?.cancel()
        isRunning = false
        secondsRemaining = selectedDuration * 60
    }

    private func complete() {
        timer?.cancel()
        isRunning = false
        totalMinutes += selectedDuration
        sessionsCompleted += 1
        secondsRemaining = selectedDuration * 60
    }

    var progress: Double {
        let total = selectedDuration * 60
        return total > 0 ? Double(total - secondsRemaining) / Double(total) : 0
    }

    var timeString: String {
        let m = secondsRemaining / 60
        let s = secondsRemaining % 60
        return String(format: "%02d:%02d", m, s)
    }
}

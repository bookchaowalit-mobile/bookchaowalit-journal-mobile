import SwiftUI
import Combine
import MindSpaceCore

// Domain types (JournalEntry, Mood, JournalStats, MeditationSession) live in
// MindSpaceCore so they can be unit-tested without SwiftUI.

extension Mood {
    var color: Color {
        switch self {
        case .great: return .green
        case .good: return .mint
        case .okay: return .yellow
        case .low: return .orange
        case .bad: return .red
        }
    }
}

// MARK: - Journal Store
final class JournalStore: ObservableObject {
    @Published var entries: [JournalEntry] = []

    private let key = "mindspace_journal"

    init() { load() }

    func addEntry(title: String, content: String, mood: Mood, tags: [String] = []) {
        let t = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let c = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty, !c.isEmpty else { return }
        entries.insert(JournalEntry(title: t, content: c, mood: mood, tags: tags), at: 0)
        save()
    }

    func deleteEntry(_ id: UUID) {
        entries.removeAll { $0.id == id }
        save()
    }

    var moodCounts: [Mood: Int] { JournalStats.moodCounts(entries) }

    var streakDays: Int { JournalStats.streakDays(entries, today: Date(), calendar: .current) }

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
/// Drives a `MeditationSession` with a one-second timer and publishes its state.
final class MeditationTimer: ObservableObject {
    @Published private(set) var session = MeditationSession()
    private var timer: AnyCancellable?

    var isRunning: Bool { session.isRunning }
    var secondsRemaining: Int { session.secondsRemaining }
    var totalMinutes: Int { session.totalMinutes }
    var sessionsCompleted: Int { session.sessionsCompleted }
    var selectedDuration: Int { session.selectedMinutes }
    var availableDurations: [Int] { MeditationSession.availableDurations }
    var progress: Double { session.progress }
    var timeString: String { session.timeString }

    func select(minutes: Int) { session.select(minutes: minutes) }

    func start() {
        session.start()
        timer?.cancel()
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            guard let self else { return }
            if self.session.tick() { self.timer?.cancel() }
        }
    }

    func pause() {
        session.pause()
        timer?.cancel()
    }

    func reset() {
        timer?.cancel()
        session.reset()
    }
}

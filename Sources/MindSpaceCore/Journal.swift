import Foundation

public enum Mood: String, Codable, CaseIterable, Identifiable {
    case great = "Great", good = "Good", okay = "Okay", low = "Low", bad = "Bad"

    public var id: String { rawValue }

    public var emoji: String {
        switch self {
        case .great: return "😊"
        case .good: return "🙂"
        case .okay: return "😐"
        case .low: return "😔"
        case .bad: return "😢"
        }
    }

    /// 5 (great) … 1 (bad), for averages.
    public var score: Int {
        switch self {
        case .great: return 5
        case .good: return 4
        case .okay: return 3
        case .low: return 2
        case .bad: return 1
        }
    }
}

public struct JournalEntry: Identifiable, Codable, Equatable {
    public let id: UUID
    public var title: String
    public var content: String
    public var mood: Mood
    public var date: Date
    public var tags: [String]

    public init(id: UUID = UUID(), title: String, content: String, mood: Mood, date: Date = Date(), tags: [String] = []) {
        self.id = id
        self.title = title
        self.content = content
        self.mood = mood
        self.date = date
        self.tags = tags
    }
}

public enum JournalStats {
    /// Parses the comma-separated tag field: trims, drops a leading `#`,
    /// lower-cases, removes empties and duplicates (keeping first order).
    public static func parseTags(_ raw: String) -> [String] {
        var seen = Set<String>()
        var tags: [String] = []
        for part in raw.split(separator: ",") {
            var t = part.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            if t.hasPrefix("#") { t.removeFirst() }
            t = t.trimmingCharacters(in: .whitespaces)
            if !t.isEmpty, seen.insert(t).inserted { tags.append(t) }
        }
        return tags
    }

    /// Consecutive days with at least one entry, ending today — or yesterday,
    /// so the streak is not shown as broken before today's entry is written.
    public static func streakDays(_ entries: [JournalEntry], today: Date, calendar: Calendar) -> Int {
        let days = Set(entries.map { calendar.startOfDay(for: $0.date) })
        var day = calendar.startOfDay(for: today)
        if !days.contains(day) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: day), days.contains(yesterday) else { return 0 }
            day = yesterday
        }
        var streak = 0
        while days.contains(day) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }
        return streak
    }

    public static func moodCounts(_ entries: [JournalEntry]) -> [Mood: Int] {
        Dictionary(entries.map { ($0.mood, 1) }, uniquingKeysWith: +)
    }

    /// Share of entries per mood (0...1); 0 for every mood when there are no entries.
    public static func moodShare(_ entries: [JournalEntry], _ mood: Mood) -> Double {
        guard !entries.isEmpty else { return 0 }
        return Double(moodCounts(entries)[mood] ?? 0) / Double(entries.count)
    }

    /// Average mood score (1...5), nil without entries.
    public static func averageMood(_ entries: [JournalEntry]) -> Double? {
        guard !entries.isEmpty else { return nil }
        return Double(entries.reduce(0) { $0 + $1.mood.score }) / Double(entries.count)
    }

    /// Entries whose title, content or tags contain `query` (case-insensitive), newest first.
    public static func search(_ entries: [JournalEntry], _ query: String) -> [JournalEntry] {
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        let matches = q.isEmpty ? entries : entries.filter { e in
            e.title.lowercased().contains(q) || e.content.lowercased().contains(q) || e.tags.contains(where: { $0.contains(q) })
        }
        return matches.sorted { $0.date > $1.date }
    }
}

import Foundation

/// Pure meditation countdown state; the UI drives it with `tick()` once per second.
public struct MeditationSession: Equatable {
    public static let availableDurations = [1, 3, 5, 10, 15, 20, 30]

    public private(set) var selectedMinutes: Int
    public private(set) var secondsRemaining: Int
    public private(set) var isRunning = false
    public private(set) var sessionsCompleted = 0
    public private(set) var totalMinutes = 0

    public init(minutes: Int = 5) {
        let m = MeditationSession.availableDurations.contains(minutes) ? minutes : 5
        selectedMinutes = m
        secondsRemaining = m * 60
    }

    /// Changes the duration; ignored while running or for unsupported values.
    public mutating func select(minutes: Int) {
        guard !isRunning, MeditationSession.availableDurations.contains(minutes) else { return }
        selectedMinutes = minutes
        secondsRemaining = minutes * 60
    }

    /// Starts, or resumes after a pause from the remaining time.
    public mutating func start() {
        if secondsRemaining <= 0 { secondsRemaining = selectedMinutes * 60 }
        isRunning = true
    }

    public mutating func pause() { isRunning = false }

    public mutating func reset() {
        isRunning = false
        secondsRemaining = selectedMinutes * 60
    }

    /// Advances one second. Returns true when this tick completed the session.
    @discardableResult
    public mutating func tick() -> Bool {
        guard isRunning else { return false }
        if secondsRemaining > 1 {
            secondsRemaining -= 1
            return false
        }
        isRunning = false
        sessionsCompleted += 1
        totalMinutes += selectedMinutes
        secondsRemaining = selectedMinutes * 60
        return true
    }

    public var progress: Double {
        let total = selectedMinutes * 60
        return total > 0 ? Double(total - secondsRemaining) / Double(total) : 0
    }

    /// "MM:SS"
    public var timeString: String {
        let m = secondsRemaining / 60
        let s = secondsRemaining % 60
        return (m < 10 ? "0" : "") + "\(m):" + (s < 10 ? "0" : "") + "\(s)"
    }
}

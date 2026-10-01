import XCTest
@testable import MindSpaceCore

final class JournalTests: XCTestCase {
    private var calendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "Asia/Bangkok")!
        return c
    }()

    private func date(_ day: Int, hour: Int = 9) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 9, day: day, hour: hour))!
    }

    private func entry(_ day: Int, _ mood: Mood = .good, hour: Int = 9, tags: [String] = []) -> JournalEntry {
        JournalEntry(title: "Day \(day)", content: "Notes", mood: mood, date: date(day, hour: hour), tags: tags)
    }

    func testParseTags() {
        XCTAssertEqual(JournalStats.parseTags(" Work, #exercise ,, work,  sleep "), ["work", "exercise", "sleep"])
        XCTAssertEqual(JournalStats.parseTags(""), [])
    }

    func testStreakCountsConsecutiveDays() {
        let entries = [entry(28), entry(29, hour: 23), entry(30, hour: 0), entry(30, hour: 22), entry(25)]
        XCTAssertEqual(JournalStats.streakDays(entries, today: date(30, hour: 12), calendar: calendar), 3)
    }

    func testStreakSurvivesUntilTodaysEntry() {
        let entries = [entry(28), entry(29)]
        XCTAssertEqual(JournalStats.streakDays(entries, today: date(30), calendar: calendar), 2)
        XCTAssertEqual(JournalStats.streakDays(entries, today: date(30, hour: 23), calendar: calendar), 2)
        XCTAssertEqual(JournalStats.streakDays([entry(27)], today: date(30), calendar: calendar), 0)
        XCTAssertEqual(JournalStats.streakDays([], today: date(30), calendar: calendar), 0)
    }

    func testMoodStatistics() throws {
        let entries = [entry(1, .great), entry(2, .great), entry(3, .bad), entry(4, .okay)]
        XCTAssertEqual(JournalStats.moodCounts(entries)[.great], 2)
        XCTAssertNil(JournalStats.moodCounts(entries)[.low])
        XCTAssertEqual(JournalStats.moodShare(entries, .great), 0.5, accuracy: 1e-9)
        XCTAssertEqual(JournalStats.moodShare([], .great), 0)
        XCTAssertEqual(try XCTUnwrap(JournalStats.averageMood(entries)), 3.5, accuracy: 1e-9)
        XCTAssertNil(JournalStats.averageMood([]))
        XCTAssertEqual(Mood.allCases.map(\.id), ["Great", "Good", "Okay", "Low", "Bad"])
    }

    func testSearchNewestFirst() {
        let entries = [entry(1, tags: ["work"]), entry(3, tags: ["gym"]), entry(2, tags: ["workout"])]
        XCTAssertEqual(JournalStats.search(entries, "WORK").map(\.title), ["Day 2", "Day 1"])
        XCTAssertEqual(JournalStats.search(entries, " ").map(\.title), ["Day 3", "Day 2", "Day 1"])
    }

    func testEntriesRoundTripThroughJSON() throws {
        let e = entry(5, .low, tags: ["a"])
        let decoded = try JSONDecoder().decode([JournalEntry].self, from: JSONEncoder().encode([e]))
        XCTAssertEqual(decoded, [e])
    }
}

final class MeditationSessionTests: XCTestCase {
    func testCountdownCompletesAndRecordsStats() {
        var s = MeditationSession(minutes: 1)
        XCTAssertEqual(s.timeString, "01:00")
        XCTAssertFalse(s.tick()) // not running
        s.start()
        for _ in 0..<59 { XCTAssertFalse(s.tick()) }
        XCTAssertEqual(s.timeString, "00:01")
        XCTAssertEqual(s.progress, 59.0 / 60.0, accuracy: 1e-9)
        XCTAssertTrue(s.tick())
        XCTAssertFalse(s.isRunning)
        XCTAssertEqual(s.sessionsCompleted, 1)
        XCTAssertEqual(s.totalMinutes, 1)
        XCTAssertEqual(s.secondsRemaining, 60)
    }

    func testPauseResumeAndReset() {
        var s = MeditationSession(minutes: 3)
        s.start()
        s.tick(); s.tick()
        s.pause()
        s.tick()
        XCTAssertEqual(s.secondsRemaining, 178)
        s.start()
        s.tick()
        XCTAssertEqual(s.timeString, "02:57")
        s.reset()
        XCTAssertEqual(s.secondsRemaining, 180)
        XCTAssertFalse(s.isRunning)
    }

    func testSelectIsIgnoredWhileRunningOrInvalid() {
        var s = MeditationSession()
        XCTAssertEqual(s.selectedMinutes, 5)
        s.select(minutes: 7)
        XCTAssertEqual(s.selectedMinutes, 5)
        s.select(minutes: 10)
        XCTAssertEqual(s.secondsRemaining, 600)
        s.start()
        s.select(minutes: 1)
        XCTAssertEqual(s.selectedMinutes, 10)
        XCTAssertEqual(MeditationSession(minutes: 2).selectedMinutes, 5)
    }
}

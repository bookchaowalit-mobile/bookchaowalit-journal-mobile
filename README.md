# MindSpace — Journal & Meditation (Mobile)

SwiftUI app for journaling and guided breathing: write mood-tagged journal
entries, run a meditation countdown, and see streaks and mood statistics.

Part of [Chaowalit Greepoke](https://bookchaowalit.com)'s 101 Portfolio Projects.

## Structure

- `Sources/MindSpaceCore` — Foundation-only domain logic, unit-tested in
  `Tests/MindSpaceCoreTests` (XCTest):
  - `JournalEntry` / `Mood` (Codable), tag parsing (trim, `#`-strip, de-dup)
  - streak calculation (today or yesterday counts, time-zone aware via `Calendar`)
  - mood counts, shares and average, search (newest first)
  - `MeditationSession`: pure countdown state machine (select, start, pause,
    resume, reset, tick, completion stats, progress, `MM:SS`)
- `Sources/MindSpace` — SwiftUI executable target (Breathe / Journal / Stats
  tabs). `JournalStore` persists entries in `UserDefaults`; `MeditationTimer`
  drives `MeditationSession` with a one-second Combine timer.

The code has **not been compiled outside CI** (it was written without a Swift
toolchain); the macOS CI job is the first real build. See
[docs/UPGRADE-PLAN.md](docs/UPGRADE-PLAN.md).

## Tech Stack

- **UI:** SwiftUI (iOS 17+; macOS 14+ so SwiftPM can build on a Mac)
- **Language:** Swift 5.9+
- **Tests:** XCTest via SwiftPM

## Getting Started

```bash
swift build
swift test          # runs MindSpaceCoreTests
open Package.swift  # opens in Xcode 15+
```

CI (`.github/workflows/build.yml`, macOS 14) runs `swift build` and
`swift test`; failures fail the workflow.

## Related

- **Frontend:** [bookchaowalit-website/journal-frontend](https://github.com/bookchaowalit-website/bookchaowalit-journal-frontend)
- **Portfolio:** [bookchaowalit.com](https://bookchaowalit.com)

## License

MIT

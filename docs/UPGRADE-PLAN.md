# Upgrade plan

## Current state

Score: 4/10 (was 2/10) — a real (if small) SwiftUI app with its logic now in a
tested core module and honest CI; nothing has been compiled yet because no
Swift toolchain was available when this pass was made.

## Backlog

- P0: Confirm the macOS CI job is green (`swift build` + `swift test`); fix any
  compile errors it reports first.
- P1: Add an iOS simulator build to CI
  (`xcodebuild -scheme MindSpace -destination 'generic/platform=iOS Simulator' build`).
- P1: Persist meditation stats (sessions / minutes) — they reset on every launch.
- P1: Edit existing journal entries; confirm before delete.
- P2: Move persistence from `UserDefaults` to SwiftData or a JSON file (entries can grow large).
- P2: Accessibility: VoiceOver labels for the mood picker emojis and timer ring.

## Done in this pass (pass 1)

- Extracted `MindSpaceCore` (journal stats, tag parsing, meditation session
  state machine) with 9 XCTest cases.
- Fixed compile errors in the original code: `let availableDurations: [Int] { … }`
  (a `let` cannot have a getter) and `ForEach(Mood.allCases)` without
  `Identifiable` conformance.
- Fixed behaviour: streak no longer shows 0 before today's entry is written;
  blank titles/content (whitespace only) can no longer be saved; tags are
  normalised; the timer uses `[weak self]` and cannot double-schedule.
- Toolbar placements changed to cross-platform ones so the package also builds
  on macOS (CI host).
- CI: runs `swift build` + `swift test` (was a release build of a target that could not compile).
- Added this README (the repo had none).

## Done in this pass (pass 2)

- Static compile review only (no Swift toolchain in this environment): read every
  source and test file for type/API errors (access levels across modules, tuple
  labels, closure destructuring, result-builder declarations, macOS 14/iOS 17
  API availability, `@testable` usage). No compile errors found; nothing changed.
  All files also parse cleanly with tree-sitter-swift.
- The P0 item (confirm the macOS `swift build` / `swift test` CI job is green) stays open.

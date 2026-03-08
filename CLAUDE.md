# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test Commands

Build the app:
```bash
xcodebuild -project Tune.xcodeproj -scheme Tune -destination 'platform=iOS Simulator,name=iPhone 17' build
```

Run unit tests:
```bash
xcodebuild -project Tune.xcodeproj -scheme Tune -destination 'platform=iOS Simulator,name=iPhone 17' test
```

Run a single test:
```bash
xcodebuild -project Tune.xcodeproj -scheme Tune -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:TuneTests/TuneTests/example test
```

Run UI tests only:
```bash
xcodebuild -project Tune.xcodeproj -scheme Tune -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:TuneUITests test
```

## Project Overview

- **Platform**: iOS/iPadOS (`TARGETED_DEVICE_FAMILY = "1,2"`)
- **Deployment target**: iOS 26.2
- **Language**: Swift 5.0, SwiftUI
- **Bundle ID**: `github.io.3rianO3yrne.Tune`

## Architecture

This is an early-stage SwiftUI app. The entry point is `TuneApp.swift` (`@main`), which presents `ContentView` inside a `WindowGroup`.

- `Tune/` — app source (SwiftUI views, models, etc.)
- `TuneTests/` — unit tests using Swift Testing framework (`import Testing`, `@Test` macros, `#expect(...)`)
- `TuneUITests/` — UI tests using XCTest (`XCUIApplication`)

Note: `TuneTests` uses the newer Swift Testing framework, not XCTest — use `@Test` and `#expect` rather than `XCTestCase`.

## File Structure Conventions

```
Tune/
├── Engine/          # Audio processing, TunerEngine
├── Models/          # Plain data types, errors, value types
├── Utilities/       # Shared helpers, math, extensions
└── Views/
    ├── Components/  # Reusable, single-responsibility SwiftUI views
    │                #   One component per file, named after the type
    │                #   Design tokens (Color extensions, etc.) go here too
    ├── Settings/    # Settings-related sheets and popovers
    └── (root)       # Screen-level views (ContentView, TunerView, TunerDialView)
```

**Rules:**
- Each file in `Views/Components/` contains one primary view (and any tightly coupled private helpers).
- Screen-level "shell" views that compose components live directly in `Views/`.
- When a view grows large, extract sub-views into `Views/Components/` rather than nesting private structs in the same file.

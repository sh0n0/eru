# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Eru is a macOS SwiftUI app (targeting macOS 26.5) that integrates with OpenAI via the [MacPaw/OpenAI](https://github.com/MacPaw/OpenAI) Swift package (v0.4.9).

## Build & Test

All builds and tests run through Xcode. Use `xcodebuild` from the repo root:

```bash
# Build
xcodebuild -project Eru.xcodeproj -scheme Eru -configuration Debug build

# Run unit tests (Swift Testing framework)
xcodebuild test -project Eru.xcodeproj -scheme Eru -only-testing:EruTests

# Run UI tests
xcodebuild test -project Eru.xcodeproj -scheme Eru -only-testing:EruUITests

# Run a single test (Swift Testing uses test function names)
xcodebuild test -project Eru.xcodeproj -scheme Eru -only-testing:EruTests/EruTests/example
```

## Architecture

- **`Eru/EruApp.swift`** — `@main` entry point, sets up the `WindowGroup` scene.
- **`Eru/ContentView.swift`** — Root SwiftUI view.
- **`EruTests/`** — Unit tests using Swift Testing (`@Test`, `#expect`).
- **`EruUITests/`** — UI tests using XCTest/XCUIAutomation.

### Dependencies

- **MacPaw/OpenAI** (`0.4.9`) — Swift client for the OpenAI API, pulled via Swift Package Manager. Linked only to the main `Eru` target.

## Key Details

- Bundle ID: `com.sh0n0.Eru`
- Swift version: 5.0
- Minimum deployment: macOS 26.5
- Unit tests use the **Swift Testing** framework (not XCTest) — use `@Test` and `#expect(...)` for new tests in `EruTests`.

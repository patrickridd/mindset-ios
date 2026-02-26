# AGENTS.md

## Cursor Cloud specific instructions

### Platform constraint

This is a **native iOS app** (SwiftUI + SwiftData) that requires **macOS with Xcode 26.2+** and an iOS Simulator to build and run the full application. The Cloud Agent Linux VM **cannot** compile Xcode project targets or run the iOS Simulator.

### What works on Linux

| Capability | Command | Notes |
|---|---|---|
| **Lint (swift-format)** | `swift-format lint --configuration .swift-format.json --recursive Packages/ mindset-ios/ mindset-iosTests/` | Uses the repo's `.swift-format.json` config |
| **Format (auto-fix)** | `swift-format format --configuration .swift-format.json --in-place --recursive Packages/` | Applies formatting fixes |
| **Build Domain package** | `cd Packages/Domain && swift build` | Pure business logic; no iOS-only deps |
| **Resolve SPM deps** | `cd Packages/<Name> && swift package resolve` | Validates remote dependency graph |
| **Package manifest check** | `cd Packages/<Name> && swift package dump-package` | Validates Package.swift syntax |

### What does NOT work on Linux

- `xcodebuild` / `swift build` for any package that imports SwiftUI, SwiftData, or UIKit (all Feature packages, SharedUI, Data)
- Running the app or iOS Simulator
- Unit/UI tests that reference iOS frameworks
- The `DomainTests` target has pre-existing compilation errors (protocol renamed from `GratitudeRepository` to `MindsetRepository` but test stubs not updated)

### Swift toolchain

Swift 6.2.3 is installed via [swiftly](https://swift.org/install/linux) at `~/.local/share/swiftly/`. The PATH is set in `~/.bashrc`. If `swift` is not found, run:

```bash
source ~/.bashrc
```

### Project structure overview

See `Context.md` for the full codebase map, design system, and roadmap. Key points:

- **13 local SPM packages** under `Packages/` (Domain, Data, 8 Feature modules, SharedUI, SharedUtils, SharedLocalization)
- **Service Factory** (`mindset-ios/Main/ServiceFactory.swift`) switches mock/real services; Debug builds default to all mocks (no API keys needed)
- **Gitignored secrets**: `Config.xcconfig` (Gemini API key), `GoogleService-Info.plist` (Firebase config)
- **Remote SPM deps**: Firebase iOS SDK, Google Generative AI (Gemini), Inject (hot reload)

<skills_system priority="1">

## Available Skills

<!-- SKILLS_TABLE_START -->
<usage>
When users ask you to perform tasks, check if any of the available skills below can help complete the task more effectively. Skills provide specialized capabilities and domain knowledge.

How to use skills:
- Invoke: `npx openskills read <skill-name>` (run in your shell)
  - For multiple: `npx openskills read skill-one,skill-two`
- The skill content will load with detailed instructions on how to complete the task
- Base directory provided in output for resolving bundled resources (references/, scripts/, assets/)

Usage notes:
- Only use skills listed in <available_skills> below
- Do not invoke a skill that is already loaded in your context
- Each skill invocation is stateless
</usage>

<available_skills>

<skill>
<name>swift-concurrency</name>
<description>'Expert guidance on Swift Concurrency best practices, patterns, and implementation. Use when developers mention: (1) Swift Concurrency, async/await, actors, or tasks, (2) "use Swift Concurrency" or "modern concurrency patterns", (3) migrating to Swift 6, (4) data races or thread safety issues, (5) refactoring closures to async/await, (6) @MainActor, Sendable, or actor isolation, (7) concurrent code architecture or performance optimization, (8) concurrency-related linter warnings (SwiftLint or similar; e.g. async_without_await, Sendable/actor isolation/MainActor lint).'</description>
<location>project</location>
</skill>

</available_skills>
<!-- SKILLS_TABLE_END -->

</skills_system>

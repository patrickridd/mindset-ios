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

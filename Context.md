# Project: Mindset Ritual App (MLP)

## 0. Codebase Map (Where Things Live)
- **App entry:** App entry: Main/MindsetApp.swift — Instantiates AppDependencyContainer.
- **Composition Root:** Main/AppDependencyContainer.swift — The single source of truth for the app's dependency graph. Assembles Repos, Use Cases, and Services.
- **Development Module (Packages/Development):** NEW. Sanctuary for Dev-only tools. Contains DebugSettings, MockServices, DebugOverlay, and EnvironmentWatermark.
- **Service Factory:** `mindset-ios/Main/ServiceFactory.swift` — centralized factory for creating services (Auth, Subscription, AI) and repositories. Switches between real and mock implementations based on `ServiceConfiguration` (mock in Debug, real in Release).
- **SharedUtils:** Contains AppLogger (Protocol) and HapticManager.
- **Navigation:** `FeatureNavigation` — `MainCoordinator`, `MainCoordinatorView`, `MainTabView`. Only the app and coordinator import Feature modules; Features never import each other.
- **Package dependency direction:** App → Feature* + Domain + Data. Domain has no dependency on Data or Feature. Data depends only on Domain (protocols). Feature modules depend on Domain (+ Data when needed) and optionally SharedUI/SharedUtils.
- **Domain** (`Packages/Domain`): Entities, Models, Protocols, UseCases, Logic (PromptEngine, PromptLibrary), Services (AIAnalysisService), Mocks, Errors. Pure business logic; no UI, no framework types for persistence.
- **Data** (`Packages/Data`): `SD*` types — Repositories (SDMindsetRepository, SDUserRepository), Services (GeminiAIService, SDPersistenceService, RevenueCatSubscriptionService, FirebaseAuthService, FirebaseSyncService), Model (SDMindsetEntry, SDPromptResponse, SDUserProfile), AppConfig, UserDefault property wrapper.
- **Feature modules:** FeatureDashboard, FeatureHistory, FeatureMindset, FeatureOnboarding, FeatureAuth, FeatureSubscription — each has View(s) and ViewModel(s). FeatureMindset has Components (e.g. AIReflectionCard) and Mocks for previews.
- **Shared:** SharedUI (MindsetColors, MindsetFonts, MindsetLayout), SharedUtils (DebugLogger, HapticManager, InjectionBootstrap), SharedLocalization (common localized strings).

## 1. Goal & Vision
- **Objective:** Reach $10k MRR by providing premium AI-driven daily Gratitude and Stoic reflections.
- **Vibe:** Positive, habit-forming, premium, focused, and high-performance.

## 2. MLP (Minimum Lovable Product) Overview

**What it is:** A gratitude and mindset journaling app meets Duolingo — fun, gamified, habit-forming.

**Foundations:**
- Positive Psychology, Stoic philosophy, Cognitive Behavioral Psychology
- Scientifically proven daily exercises for healthier, happier, more resilient mindset

**Prompt categories (curated via onboarding quiz):**
- Gratitude
- Memento mori
- Goal setting
- "What went well today?"
- "What did you forget to give yourself credit for?"
- …and similar evidence-based prompts

**Gamification & habit-building:**
- Daily streak tracking
- XP points
- Archetype building
- Weekly summaries
- AI feedback based on prompt responses
- Dopamine-hitting UI: animations, haptic feedback, sound effects
- Progress capture that motivates users to keep going

**Future vision:**
- XP points → Zen garden or other visual representation of progress on the Dashboard

## 3. MLP Roadmap (Feature Priorities)

| Phase | Focus |
|-------|-------|
| **Core** | Quiz/onboarding → curated prompts, daily ritual flow, AI feedback, streak |
| **Gamification** | XP, archetype building, weekly summaries, animations, haptics, sound |
| **Engagement** | Progress visualization (Zen garden / dashboard representation) |

## 4. Onboarding & Auth Flow (Product Decision)

**Order: Value-first, quiz-driven conversion funnel (Duolingo-style).**

### Complete Onboarding Flow (14 Steps)

1. **Intro/Welcome** - Set expectations, "5 minutes to build your mindset ritual"
2. **Quiz (5 questions)** - Headspace, Mental Muscle, Response to Setback, Habit Goal, AI Coach Tone
3. **Analyzing** - Analyzing (Lottie: anim_analyzing.lottie) — Trigger SILENT signInAnonymously() here.
4. **Archetype Reveal** - Hero moment: "Your Mindset Archetype: The Stoic Seeker" (personalized identity, creates ownership). User is now an "Anonymous Owner" of this data.
5. **Pain Screen 1** - "Feeling overwhelmed or restless?" (address headspace issues)
6. **Pain Screen 2** - "Stuck in the same mental patterns?" (address lack of progress)
7. **Pain Screen 3** - "Failed to build a daily journaling habit before?" (address habit failure)
8. **How App Can Help** - Features overview + Yesterday Bridge explanation
9. **Social Proof** - Reviews, testimonials, "Join 10k+ members on a daily mindset streak"
10. **AI Coach Introduction** - "Meet your AI coach [Name], calibrated to your [tone preference]" (personalization)
11. **Custom Plan** - Daily ritual preview: 5 min/day, curated prompts, XP + streak system, AI feedback
12  **Personalization Finalized** - "Your plan is ready. Let's start your first ritual."
13. **Paywall** - (or Discounted Paywall for A/B testing)
14. **Main App** - Dashboard

**Rationale:**
- Quiz first = value-first, lower drop-off, investment before friction
- Archetype reveal = hero moment, ownership, differentiation
- Pain screens = emotional connection, urgency before paywall
- Auth after quiz but before paywall = profile ready to save, can't purchase without auth anyway
- Custom plan + social proof = maximize perceived value before ask

## 5. Tech Stack (2026 Standards)
- **UI:** SwiftUI Use "*/mindset-ios/.agents/skills/swiftui-expert-skill" as standards guide
- **AI:** Gemini 2.0 Flash (`GoogleGenerativeAI`).
- **Data:** SwiftData for local persistence, Firebase Firestore for cloud sync.
- **Auth:** Firebase Auth (Sign in with Apple, anonymous fallback).
- **Subscriptions:** RevenueCat (already integrated).
- **Architecture:** Modular (Domain, Data, Feature modules). Use ".cursor/rules/architecture-di.mdc" as guide
- **Navigation:** Coordinator Pattern.
- **Comments and Documentation:**  Use ".cursor/rules/swift-documentation.mdc" as guide

## 6. Critical Build Configurations
- **Hot Reload:** InjectionIII is configured (must use GitHub version, NOT App Store version).
- **Flags:**
  - Other Linker Flags: `-Wl,-interposable`
  - Other Swift Flags: `-Xfrontend -disable-batch-mode -enable-bare-slash-regex`
  - User-Defined: `SWIFT_MODULE_CACHE_PATH` points to `$(DERIVED_DATA_DIR)/ModuleCache.noindex`
- **Note:** The `-Xfrontend -interposable` flag does NOT work (unknown argument error). Only the linker flag `-Wl,-interposable` is needed.

## 7. Current Task
- Implementing complete onboarding flow (14 steps) with Firebase Auth integration.
- Creating `FeatureAuth` module for Sign in with Apple.
- Setting up Firebase Firestore for cloud sync (SwiftData ↔ Firestore).

## 8. Build Configuration
- **Hot Reload:** InjectionIII via `-Wl,-interposable` in Other Linker Flags.
- **Note:** Do NOT use `-Xfrontend -interposable` (causes unknown argument error). The linker flag alone is sufficient.

## 9. Build Troubleshooting
- **Error:** "Unknown argument: '-interposable'"
- **Solution:** Do NOT use `-Xfrontend -interposable` in Swift Flags. Only use `-Wl,-interposable` in Other Linker Flags.
- **Error:** "cannot get default cache directory" during hot reload
- **Solution:** Use the GitHub version of InjectionIII (not the App Store version). The App Store version runs in a sandbox that prevents access to the Swift compiler's cache directories. Download from: https://github.com/johnno1962/InjectionIII/releases

## 10. Project Location
- **Root Path:** ~/Developer/mindset-ios/
- **Note:** Always ensure terminal commands are run from this root to maintain Git and InjectionIII connectivity.

## 11. Hot Reload Stability (2026 Update)
- **App Version:** Use the GitHub release of InjectionIII (https://github.com/johnno1962/InjectionIII/releases), NOT the App Store version. The App Store version's sandbox causes "cannot get default cache directory" errors.
- **Flag Fix:** Use `-Xfrontend -disable-batch-mode` in Other Swift Flags.
- **Cache Fix:** User-Defined `SWIFT_MODULE_CACHE_PATH` set to `$(DERIVED_DATA_DIR)/ModuleCache.noindex`.
- **Permission:** InjectionIII REQUIRES "Full Disk Access" in System Settings > Privacy & Security.

## 12. AI Integration
- **Provider:** Google Gemini 2.0 Flash.
- **Service:** `GeminiAIService`.
- **Security:** Do NOT hardcode API Keys. Use `ProcessInfo.processInfo.environment` or a secure `Config.plist` that is gitignored.

## 13. Design System (SharedUI)

Use `MindsetColors`, `MindsetFonts`, and `MindsetLayout` from SharedUI for all Feature views. Never use raw colors, fonts, or magic numbers — use semantic tokens for consistency and easy theme updates.

### MindsetColors

**Backgrounds:** `backgroundDark`, `backgroundDarkSoft`, `backgroundWarmAccent` (dark screens) • `backgroundGrouped(for:)`, `backgroundSecondary(for:)` (adaptive, pass `colorScheme`)

**Text:** `textPrimary`, `textSecondary`, `textMuted` (dark BGs) • `textPrimaryAdaptive(for:)`, `textSecondaryAdaptive(for:)`, `textDisabled(for:)`, `textOnAccent(for:)`, `labelAccent(for:)` (adaptive, pass `colorScheme`)

**Accents:** `accentOrange`, `accentOrangeSoft`, `accentCoral` (motivation, CTAs, progress)

**Success:** `successGreen`, `successEmerald` • **Stoic:** `stoicSlate`, `stoicSlateSoft` (borders, reflective content) • **Achievement:** `achievementGold` (XP, badges)

**UI:** `borderSubtle`, `borderAccent`, `fillSubtle`, `progressInactive`, `buttonDisabledBackground(for:)`, `dismissButtonIcon(for:)` (adaptive, pass `colorScheme`)

### MindsetFonts

**Display (serif):** `displayHeadline`, `displayLarge`, `promptHeadline` • **Body (sans):** `body`, `promptQuestion`, `bodyMedium`, `subheadline`, `footnote`, `callout` • **Labels:** `label`, `labelUppercase`, `caption`, `captionBold` • **UI:** `button`, `featureTitle`, `title2`, `screenTitle`, `statValue`

### MindsetLayout

**Spacing:** `spacing4`–`spacing40` (VStack/HStack) • **Padding:** `paddingSmall` (8), `paddingMedium` (12), `paddingStandard` (16), `paddingLarge` (20), `paddingCard` (25), `paddingScreenHorizontal` (30) • **Corner radius:** `radiusSmall` (4), `radiusStandard` (12), `radiusButton` (14), `radiusCard` (16), `radiusCardLarge` (20), `radiusIdentityCard` (24) • **Dimensions:** `progressBarHeight`, `buttonHeight`, `iconSmall`, `iconLarge`, `heroCircleSize`, `textEditorMinHeight` • **Other:** `borderWidth`, `shadowRadius`, `glowBlurRadius`

**Sizing preference:** Prefer views and controls that size to their content. Avoid static or max widths/heights unless necessary—e.g. to prevent overflow, enforce a minimum tap target (e.g. 44pt height), or cap width for readability. Let height follow content; use `frame(maxWidth:)` only when needed.

### Dismiss / close button (modals and full-screen flows)

**Standard:** Use a toolbar **`Button(role: .cancel)`** with `Image(systemName: "xmark")` and **`HapticManager.selection()`** in the action (then call `viewModel.dismiss()` or your dismiss callback). Use this for onboarding, paywall, and other modals/full-screen flows.

**Exception:** **`MorningRitualView`** (FeatureMindset) continues to use **`DismissButton(action: { ... })`** from SharedUI; do not change it to the toolbar button. `DismissButton` remains available in SharedUI for that screen and any future exceptions.

### Haptics (SharedUtils HapticManager)

Use **HapticManager only in Views, never in ViewModels.** Haptics are a presentation concern; the View triggers them when handling user actions or when observing state changes (e.g. `isAiThinking` → false → `HapticManager.success()`).

Use the **semantic** APIs for consistency. Prefer these over raw `impact(_:)` / `notification(_:)`:

- **`HapticManager.selection()`** — User picks one option (onboarding choice, list row, segment).
- **`HapticManager.action()`** — Primary action (submit, continue, complete step).
- **`HapticManager.success()`** — Flow or task completed (ritual done, onboarding done).
- **`HapticManager.tick()`** — Light repeated feedback (progress/XP bar tick).

### Logging (SharedUtils DebugLogger)

**NEVER use print() in production code.** Use Use the **`AppLogger`** protocol (Domain). The concrete implementation **`DebugLogger`** (SharedUtils) is injected at the App Root.

**Why DebugLogger is better:**
- ✅ Visible in UI debug overlay (persistent, doesn't disappear)
- ✅ Async, non-blocking (~0.1ms overhead vs print's blocking I/O)
- ✅ Can be disabled in release builds
- ✅ Helps remote debugging (users can take screenshots of debug overlay)
- ✅ Secure (can sanitize sensitive data)

**Usage:**
```swift
DebugLogger.shared.add("✅ User signed in: \(userID)")
DebugLogger.shared.add("❌ Dashboard load failed: \(error.localizedDescription)")
DebugLogger.shared.add("🔄 OAuth callback handled")
```

**When to use DebugLogger:**
- Auth/navigation lifecycle (sign in, sign out, flow transitions)
- Feature completion (ritual saved, onboarding done)
- Critical errors that affect UX
- State changes useful for debugging (e.g. OAuth callbacks)

**When print() is acceptable:**
- Mock/test code only (e.g. `MockAuthService`)
- Never in production ViewModels, Views, Services, or Repositories

**Best practices:**
- Use emoji prefixes: ✅ success, ❌ errors, ⚠️ warnings, 📱 events, 🔄 state changes
- Use `.localizedDescription` for errors (don't leak internal stack traces)
- Sanitize sensitive data (URLs, tokens) before logging

### ViewModels (clean architecture)

Keep ViewModels **clean**: they hold state and business logic only. Do **not** put presentation or View-layer concerns in ViewModels:

- **No HapticManager** — Views call `HapticManager` when handling taps or observing state; ViewModels never import or use it.
- **No UI types** — No `Color`, `Font`, `View` types, or layout constants; those belong in Views and SharedUI.
- **No animations** — ViewModels update state; Views decide how to animate (e.g. `withAnimation { viewModel.nextStep() }`).

**State in ViewModels:** Keep published/observable state in the ViewModel when possible. Use View `@State` only when the state would leak unnecessary framework or implementation details into the ViewModel—e.g. `@FocusState`, SwiftUI-only types, or one-off layout keys. Prefer a single source of truth in the ViewModel so business logic and tests stay in one place.

ViewModels stay testable and reusable; Views own haptics, animations, and visual feedback.

### SwiftUI View Body Composition

Compose the body of Views into smaller subviews in a **private extension** on the View. Subview implementations (header, content sections, overlays, footers) **must** live in that private extension, not in the main struct. Keep the main struct to stored properties, `init`, and `body` only; keep `body` minimal—e.g. a single ZStack or VStack that references composed subviews.

**Benefits:** Readability, easier navigation, simpler diffs, maintainability.

**Structure:**
- **Main struct:** `init`, `body` only (plus any `@State` / `@Environment` / `@FocusState` the body needs). Use `// MARK: - Body Composition` above `body`.
- **Private extension:** Put all subview implementations here. Use `// MARK: - Subviews` on the extension. No subview computed properties or helper views in the main struct.

**Example:**
```swift
// Main struct
public var body: some View {
    ZStack {
        backgroundView
        if viewModel.isLoading { initialLoadingOverlay }
        else {
            mainContentStack
            coachTipOverlay
        }
    }
}

// MARK: - Subviews

private extension SomeView {
    var backgroundView: some View { ... }
    var mainContentStack: some View { ... }
    var headerSection: some View { ... }
    var footerButtons: some View { ... }
}
```

Reference: `Packages/FeatureDashboard/Sources/FeatureDashboard/DashboardView.swift`, `Packages/FeatureMindset/Sources/FeatureMindset/MorningRitualView.swift`.

### Localization (String Management)

**NEVER use hardcoded strings or magic strings.** All user-facing text must be localized using the type-safe APIs.

Use **SharedLocalization** for common strings used across multiple features:
- `SharedLocalizedString.cancel`, `SharedLocalizedString.save`, `SharedLocalizedString.done`, etc.
- `SharedLocalizedString.Error.networkError`, `SharedLocalizedString.Error.somethingWentWrong`
- `SharedLocalizedString.Validation.requiredField`, `SharedLocalizedString.Validation.invalidEmail`
- `SharedLocalizedString.Auth.signIn`, `SharedLocalizedString.Auth.signOut`
- `SharedLocalizedString.Loading.loading`, `SharedLocalizedString.General.settings`

Use **Feature[Name]Strings** for feature-specific content:
- `FeatureAuthStrings.signInTitle`, `FeatureAuthStrings.Error.signInFailed`
- `FeatureDashboardStrings.Greeting.morning`, `FeatureDashboardStrings.Streak.title`
- `FeatureMindsetStrings.title`, `FeatureMindsetStrings.Categories.gratitude`
- `FeatureOnboardingStrings.Welcome.title`, `FeatureOnboardingStrings.Pain.overwhelmedTitle`
- `FeatureSubscriptionStrings.Feature.aiCoach`, `FeatureSubscriptionStrings.Plan.yearlyTitle`

ViewModels can return localized strings; Views display them. Both SharedLocalization and Feature[Name]Strings provide compile-time safety and autocomplete.

**Decision tree:** Is the string used in multiple features? → Use `SharedLocalizedString`. Is it unique to one feature? → Use `Feature[Name]Strings`.

See `docs/guides/LOCALIZATION_QUICK_REFERENCE.md` for complete API reference.

## 14. Configuration & Secrets (AppConfig)
- **Method:** Build-time injection via .xcconfig -> Info.plist.
- **Access:** `AppConfig.geminiAPIKey`, `AppConfig.firebaseAPIKey`.
- **Git Safety:** Config.config file is gitignored; contains the source `GEMINI_API_KEY` and Firebase config.

## 15. Documentation

All guides, architecture docs, and troubleshooting resources are organized in the `docs/` directory:

```
docs/
├── README.md              # Documentation index and navigation
├── architecture/          # System design and patterns
├── setup/                # Configuration and installation
├── guides/               # Implementation how-tos
└── troubleshooting/      # Common issues and fixes
```

**Key documentation:**
- **Architecture:** Auth decoupling, onboarding flow design, localization architecture
- **Setup:** Firebase configuration, authentication providers
- **Guides:** 
  - Service Factory pattern (real vs mock services)
  - Google Sign In via Firebase
  - Localization quick reference and examples
  - Implementation tutorials
- **Troubleshooting:** Anonymous sign-in, OAuth callbacks, Firebase errors

See [docs/README.md](docs/README.md) for complete index and quick start guide.

## 16. Firebase Integration (Auth + Firestore)

### Setup
1. **Firebase Project:** Created at console.firebase.google.com
2. **SDK:** Added via SPM (`firebase-ios-sdk`)
3. **Services:** FirebaseAuth (Sign in with Apple), Firestore (cloud sync)
4. **Configuration:** `GoogleService-Info.plist` (gitignored)

### Auth Flow (FeatureAuth Module)
- **Sign in with Apple** - Primary auth method, handled by Firebase Auth
- **Anonymous fallback** - For trial/testing without account
- **RevenueCat integration** - Firebase UID → RevenueCat user ID for subscription tracking
- **Profile sync** - SwiftData profile → Firestore on successful auth

### Data Sync Strategy
- **Local-first:** SwiftData is source of truth, always available offline
- **Cloud backup:** Firestore syncs on auth + background refresh
- **Conflict resolution:** Last-write-wins (timestamp-based)
- **Services:** `FirebaseAuthService` (auth), `FirebaseSyncService` (data sync) in Data module

### Security Rules (Firestore)
- Users can only read/write their own data (`request.auth.uid == userId`)
- Profile, entries, and prompts are user-scoped collections
- RevenueCat webhook updates subscription status server-side

## 17. Service Factory Pattern (Debug vs Production)

### Overview
The **Service Factory** pattern (`mindset-ios/Main/ServiceFactory.swift`) provides a clean, centralized way to switch between real and mock services based on build configuration.

### Architecture

**ServiceConfiguration** - Defines which services to use:
```swift
ServiceConfiguration.default    // Mock in Debug, Real in Release (default)
ServiceConfiguration.production // Force real services (for testing real backends in Debug)
ServiceConfiguration.mock       // Force mock services (for previews/UI testing)
```

**ServiceFactory** - Creates services and repositories:
- `makeAuthService()` → `FirebaseAuthService` or `MockAuthService`
- `makeSubscriptionService()` → `RevenueCatSubscriptionService` or `MockSubscriptionService`
- `makeAIService()` → `GeminiAIService` or `MockAIService`
- `makeMindsetRepository()` → `SDMindsetRepository` or `MockMindsetRepository`
- `makeUserRepository()` → `SDUserRepository` or `MockUserRepository`

### Usage in MindsetApp.swift

```swift
// Default: Mock services in Debug, Real in Release
serviceFactory = ServiceFactory(config: .default)

// Override to test with real services in Debug:
// serviceFactory = ServiceFactory(config: .production)

// All services created via factory
authService = serviceFactory.makeAuthService()
subscriptionService = serviceFactory.makeSubscriptionService()
mindsetRepository = serviceFactory.makeMindsetRepository(persistence: persistence)
// etc.
```

## 18. Rule Index (Active Intelligence)

This project utilizes **Modular MDC (Markdown Cursor)** rules to ensure high-performance AI reasoning and architectural consistency. Refer to these specialized instruction sets for specific implementation requirements:

| Rule File | Primary Responsibility | Target Scope (Globs) |
| :--- | :--- | :--- |
| **`index.mdc`** | Central map for $10k MRR vision and cross-module coordination. | `*` (Always Apply) |
| **`ui-design.mdc`** | Liquid Glass UI, `SharedUI` tokens, haptics in views, and body composition. | `**/*View.swift` |
| **`localization.mdc`** | Enforcement of type-safe strings. No hardcoded or magic strings allowed. | `**/*.swift` |
| **`data-persistence.mdc`** | Gemini 2.0 Flash, SwiftData (`SD` prefix), and Firebase sync logic. | `**/Data/**`, `**/Domain/**` |
| **`service-factory.mdc`**  and **`architecture-di.mdc`**| Dependency Injection, Mock vs. Real service logic, and App composition. | `**/Main/**`, `**/Protocols/**` |

**Developer Note:** To force the AI to adhere strictly to one of these systems during a complex task, mention the rule specifically in the prompt (e.g., *"Refactor this view according to @ui-design.mdc"*).

### Benefits

✅ **Clean separation** - One place to manage real vs mock services (no scattered `#if DEBUG` blocks)  
✅ **Type-safe** - All services conform to protocols; compile-time safety  
✅ **Performant** - Firebase skipped when using mocks → faster debug launches  
✅ **Testable** - Easy to inject mocks for tests and previews  
✅ **Secure** - No API keys loaded when using mocks  
✅ **Scalable** - Add new services by implementing protocol + adding factory method  

### Mock Services

Mock services provide:
- **Instant responses** (no network calls, no delays)
- **Pre-seeded data** for testing UI flows
- **Local-only** (no cloud sync, no API calls)
- **No API keys required**

Perfect for rapid UI development, SwiftUI previews, and testing user flows without backend dependencies.

### Adding New Services

1. Define protocol in `Domain/Protocols/`
2. Implement real service in `Data/Services/`
3. Implement mock service in `Domain/Mocks/`
4. Add factory method to `ServiceFactory`
5. Update `MindsetApp.swift` to use factory method

See `docs/guides/SERVICE_FACTORY_GUIDE.md` for complete documentation.

## 19. Architecture Quick-Start (The "AI Handshake")

When building new features, the AI MUST strictly follow this "Golden Path" to maintain the $10k MRR quality standard:

### 1. The "Protocol-First" workflow
- **Step A (Domain):** Define the data structure and a `Protocol` for the logic.
- **Step B (Data):** Create the `SD` (SwiftData) persistence or API implementation.
- **Step C (Main):** Register the new service in `ServiceFactory.swift`.
- **Step D (Feature):** Inject the Protocol into the ViewModel.

### 2. The "View Composition" Law
- Keep the `body` under 20 lines.
- Move all sub-components to a `private extension` at the bottom of the file.
- Use `HapticManager` in the View closure, never in the ViewModel logic.

### 3. The "Pure Logic" VM
- ViewModels are strictly for state and business logic.
- **Forbidden:** No `import SwiftUI`, no `Color`, no `print()`, no `HapticManager`.

### 4. Zero-Leak Localization
- If the AI sees a string like `"Hello"`, it must stop and look for the equivalent in `SharedLocalization` or `FeatureStrings`.

### 5. AI-Ready Previews
- Use `ServiceFactory.mock` to ensure SwiftUI Previews work instantly without network or API keys.

##20: The "Soft Restart" & State Reset
App Reset: The app supports a "Soft Restart" via Notification.Name.restartApp. This triggers the MindsetApp to re-instantiate the AppDependencyContainer, allowing a clean swap between Mock and Production environments without a hard process kill.
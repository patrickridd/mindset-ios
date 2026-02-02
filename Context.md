# Project: Mindset Ritual App (MLP)

## 0. Codebase Map (Where Things Live)
- **App entry:** `mindset-ios/Main/MindsetApp.swift` — composes container, repos, use cases, `MainCoordinator`, and `AppViewFactory`.
- **Navigation:** `FeatureNavigation` — `MainCoordinator`, `MainCoordinatorView`, `MainTabView`. Only the app and coordinator import Feature modules; Features never import each other.
- **Package dependency direction:** App → Feature* + Domain + Data. Domain has no dependency on Data or Feature. Data depends only on Domain (protocols). Feature modules depend on Domain (+ Data when needed) and optionally SharedUI/SharedUtils.
- **Domain** (`Packages/Domain`): Entities, Models, Protocols, UseCases, Logic (PromptEngine, PromptLibrary), Services (AIAnalysisService), Mocks, Errors. Pure business logic; no UI, no framework types for persistence.
- **Data** (`Packages/Data`): `SD*` types — Repositories (SDMindsetRepository, SDUserRepository), Services (GeminiAIService, SDPersistenceService, RevenueCatSubscriptionService, FirebaseAuthService, FirebaseSyncService), Model (SDMindsetEntry, SDPromptResponse, SDUserProfile), AppConfig.
- **Feature modules:** FeatureDashboard, FeatureHistory, FeatureMindset, FeatureOnboarding, FeatureAuth, FeatureSubscription — each has View(s) and ViewModel(s). FeatureMindset has Components (e.g. AIReflectionCard) and Mocks for previews.
- **Shared:** SharedUI (MindsetColors, MindsetFonts, MindsetLayout, DebugOverlay), SharedUtils (DebugLogger, HapticManager, InjectionBootstrap).

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
3. **Analyzing** - "Building your Identity Profile..." (investment moment, 2.5s)
4. **Archetype Reveal** - Hero moment: "Your Mindset Archetype: The Stoic Seeker" (personalized identity, creates ownership)
5. **Pain Screen 1** - "Feeling overwhelmed or restless?" (address headspace issues)
6. **Pain Screen 2** - "Stuck in the same mental patterns?" (address lack of progress)
7. **Pain Screen 3** - "Failed to build a daily journaling habit before?" (address habit failure)
8. **How App Can Help** - Features overview + Yesterday Bridge explanation
9. **Social Proof** - Reviews, testimonials, "Join 10k+ members on a daily mindset streak"
10. **AI Coach Introduction** - "Meet your AI coach [Name], calibrated to your [tone preference]" (personalization)
11. **Custom Plan** - Daily ritual preview: 5 min/day, curated prompts, XP + streak system, AI feedback
12. **Sign in with Apple** - Auth bridge to save profile and sync data (Firebase Auth)
13. **Paywall** - (or Discounted Paywall for A/B testing)
14. **Main App** - Dashboard

**Rationale:**
- Quiz first = value-first, lower drop-off, investment before friction
- Archetype reveal = hero moment, ownership, differentiation
- Pain screens = emotional connection, urgency before paywall
- Auth after quiz but before paywall = profile ready to save, can't purchase without auth anyway
- Custom plan + social proof = maximize perceived value before ask

## 5. Tech Stack (2026 Standards)
- **UI:** SwiftUI (latest) using `@Observable` and `Swift Concurrency`.
- **AI:** Gemini 2.0 Flash (`GoogleGenerativeAI`).
- **Data:** SwiftData for local persistence, Firebase Firestore for cloud sync.
- **Auth:** Firebase Auth (Sign in with Apple, anonymous fallback).
- **Subscriptions:** RevenueCat (already integrated).
- **Architecture:** Modular (Domain, Data, Feature modules).
- **Navigation:** Coordinator Pattern.

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

### DismissButton (SharedUI)

Use **`DismissButton(action: { ... })`** from SharedUI for closing/dismissing modals and full-screen flows (e.g. onboarding, morning ritual). It renders a top-right X with design-system styling; pass your dismiss callback (e.g. `viewModel.dismiss()` or coordinator callback) so behavior stays consistent across the app.

### Haptics (SharedUtils HapticManager)

Use **HapticManager only in Views, never in ViewModels.** Haptics are a presentation concern; the View triggers them when handling user actions or when observing state changes (e.g. `isAiThinking` → false → `HapticManager.success()`).

Use the **semantic** APIs for consistency. Prefer these over raw `impact(_:)` / `notification(_:)`:

- **`HapticManager.selection()`** — User picks one option (onboarding choice, list row, segment).
- **`HapticManager.action()`** — Primary action (submit, continue, complete step).
- **`HapticManager.success()`** — Flow or task completed (ritual done, onboarding done).
- **`HapticManager.tick()`** — Light repeated feedback (progress/XP bar tick).

### Logging (SharedUtils DebugLogger)

**NEVER use print() in production code.** Use **`DebugLogger`** (SharedUtils) instead for all app-level logging.

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

ViewModels stay testable and reusable; Views own haptics, animations, and visual feedback.

## 14. Configuration & Secrets (AppConfig)
- **Method:** Build-time injection via .xcconfig -> Info.plist.
- **Access:** `AppConfig.geminiAPIKey`, `AppConfig.firebaseAPIKey`.
- **Git Safety:** Config.config file is gitignored; contains the source `GEMINI_API_KEY` and Firebase config.

## 15. Firebase Integration (Auth + Firestore)

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

# Project: Mindset Ritual App (MLP)

## 0. Codebase Map (Where Things Live)
- **App entry:** `mindset-ios/Main/MindsetApp.swift` — composes container, repos, use cases, `MainCoordinator`, and `AppViewFactory`.
- **Navigation:** `FeatureNavigation` — `MainCoordinator`, `MainCoordinatorView`, `MainTabView`. Only the app and coordinator import Feature modules; Features never import each other.
- **Package dependency direction:** App → Feature* + Domain + Data. Domain has no dependency on Data or Feature. Data depends only on Domain (protocols). Feature modules depend on Domain (+ Data when needed) and optionally SharedUI/SharedUtils.
- **Domain** (`Packages/Domain`): Entities, Models, Protocols, UseCases, Logic (PromptEngine, PromptLibrary), Services (AIAnalysisService), Mocks, Errors. Pure business logic; no UI, no framework types for persistence.
- **Data** (`Packages/Data`): `SD*` types — Repositories (SDMindsetRepository, SDUserRepository), Services (GeminiAIService, SDPersistenceService, RevenueCatSubscriptionService), Model (SDMindsetEntry, SDPromptResponse, SDUserProfile), AppConfig.
- **Feature modules:** FeatureDashboard, FeatureHistory, FeatureMindset, FeatureOnboarding, FeatureSubscription — each has View(s) and ViewModel(s). FeatureMindset has Components (e.g. AIReflectionCard) and Mocks for previews.
- **Shared:** SharedUI (DebugOverlay), SharedUtils (DebugLogger, HapticManager, InjectionBootstrap).

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

**Order: Quiz first, login after.**

- User completes the 5-question quiz and sees "Building your Identity Profile..." (investment, no friction).
- Login (Sign in with Apple / optional email) is requested *after* the quiz, as the bridge to save their profile and unlock the app.
- Paywall follows login: Quiz → Login → Paywall → Main App.
- Rationale: Duolingo-style value-first, lower drop-off, stronger conversion moment when users are already invested.

## 5. Tech Stack (2026 Standards)
- **UI:** SwiftUI (latest) using `@Observable` and `Swift Concurrency`.
- **AI:** Gemini 2.0 Flash (`GoogleGenerativeAI`).
- **Data:** SwiftData for persistence.
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
- Implementing `GeminiAIService` in the Data module.
- Setting up the Dashboard to display AI-generated insights.

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

## 13. Configuration & Secrets (AppConfig)
- **Method:** Build-time injection via .xcconfig -> Info.plist.
- **Access:** `AppConfig.geminiAPIKey`.
- **Git Safety:** Config.config file is gitignored; contains the source `GEMINI_API_KEY`.

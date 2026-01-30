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
- **Objective:** Reach $10k MRR by providing premium AI-driven daily Gratitude and Stoic reflections. Think Duolingo version of a gratitude journal and other positive psychology practices. 
- **Vibe:** Positive, habit-forming, premium, focused, and high-performance.

## 2. Tech Stack (2026 Standards)
- **UI:** SwiftUI (latest) using `@Observable` and `Swift Concurrency`.
- **AI:** Gemini 2.0 Flash (`GoogleGenerativeAI`).
- **Data:** SwiftData for persistence.
- **Architecture:** Modular (Domain, Data, Feature modules).
- **Navigation:** Coordinator Pattern.

## 3. Critical Build Configurations
- **Hot Reload:** InjectionIII is configured (must use GitHub version, NOT App Store version).
- **Flags:**
  - Other Linker Flags: `-Wl,-interposable`
  - Other Swift Flags: `-Xfrontend -disable-batch-mode -enable-bare-slash-regex`
  - User-Defined: `SWIFT_MODULE_CACHE_PATH` points to `$(DERIVED_DATA_DIR)/ModuleCache.noindex`
- **Note:** The `-Xfrontend -interposable` flag does NOT work (unknown argument error). Only the linker flag `-Wl,-interposable` is needed.

## 4. Current Task
- Implementing `GeminiAIService` in the Data module.
- Setting up the Dashboard to display AI-generated insights.

## 5. Build Configuration
- **Hot Reload:** InjectionIII via `-Wl,-interposable` in Other Linker Flags.
- **Note:** Do NOT use `-Xfrontend -interposable` (causes unknown argument error). The linker flag alone is sufficient.

## 6. Build Troubleshooting
- **Error:** "Unknown argument: '-interposable'"
- **Solution:** Do NOT use `-Xfrontend -interposable` in Swift Flags. Only use `-Wl,-interposable` in Other Linker Flags.
- **Error:** "cannot get default cache directory" during hot reload
- **Solution:** Use the GitHub version of InjectionIII (not the App Store version). The App Store version runs in a sandbox that prevents access to the Swift compiler's cache directories. Download from: https://github.com/johnno1962/InjectionIII/releases

## 7. Project Location
- **Root Path:** ~/Developer/mindset-ios/
- **Note:** Always ensure terminal commands are run from this root to maintain Git and InjectionIII connectivity.

## 8. Hot Reload Stability (2026 Update)
- **App Version:** Use the GitHub release of InjectionIII (https://github.com/johnno1962/InjectionIII/releases), NOT the App Store version. The App Store version's sandbox causes "cannot get default cache directory" errors.
- **Flag Fix:** Use `-Xfrontend -disable-batch-mode` in Other Swift Flags.
- **Cache Fix:** User-Defined `SWIFT_MODULE_CACHE_PATH` set to `$(DERIVED_DATA_DIR)/ModuleCache.noindex`.
- **Permission:** InjectionIII REQUIRES "Full Disk Access" in System Settings > Privacy & Security.

## 9. AI Integration
- **Provider:** Google Gemini 2.0 Flash.
- **Service:** `GeminiAIService`.
- **Security:** Do NOT hardcode API Keys. Use `ProcessInfo.processInfo.environment` or a secure `Config.plist` that is gitignored.

## 10. Configuration & Secrets (AppConfig)
- **Method:** Build-time injection via .xcconfig -> Info.plist.
- **Access:** `AppConfig.geminiAPIKey`.
- **Git Safety:** Config.config file is gitignored; contains the source `GEMINI_API_KEY`.

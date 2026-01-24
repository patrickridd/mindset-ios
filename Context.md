# Project: Mindset Ritual App (MLP)

## 1. Goal & Vision
- **Objective:** Reach $10k MRR by providing premium AI-driven gamified Stoic reflections. Think Duolingo version of a gratitude journal and other positive psychology practices.  
- **Vibe:** Minimalist, premium, focused, and high-performance.

## 2. Tech Stack (2026 Standards)
- **UI:** SwiftUI (latest) using `@Observable` and `Swift Concurrency`.
- **AI:** Gemini 2.0 Flash (`GoogleGenerativeAI`).
- **Data:** SwiftData for persistence.
- **Architecture:** Modular (Domain, Data, Feature modules).
- **Navigation:** Coordinator Pattern.

## 3. Critical Build Configurations
- **Hot Reload:** InjectionIII is configured.
- **Flags:** - Other Linker Flags: `-Wl,-interposable`
  - Other Swift Flags: `-Xfrontend -disable-batch-mode`, `-Xfrontend -interposable`
  - User-Defined: `SWIFT_MODULE_CACHE_PATH` points to `$(DERIVED_DATA_DIR)/ModuleCache.noindex`
- **Known Issue:** InjectionIII may fail with "cannot get default cache directory"; prioritize building features over fixing this if it stalls development.

## 4. Current Task
- Implementing `GeminiAIService` in the Data module.
- Setting up the Dashboard to display AI-generated insights.

## 5. Build Configuration
- **Hot Reload:** InjectionIII via `-Xlinker -interposable`.
- **Note:** If build fails with `unknown argument`, ensure flags are split into separate lines in Xcode Build Settings or use `-Wl,-interposable`.

## 6. Build Troubleshooting
- **Error:** "Driver threw unknown argument: -interposable"
- **Solution:** Use `-Wl,-interposable` in Other Linker Flags and `-Xfrontend -interposable` in Other Swift Flags.

## 7. Project Location
- **Root Path:** ~/Developer/mindset-ios/
- **Note:** Always ensure terminal commands are run from this root to maintain Git and InjectionIII connectivity.

## 8. Hot Reload Stability (2026 Update)
- **Flag Fix:** Use `-Xfrontend=-disable-batch-mode` or `-driver-batch-count 1` to avoid Driver errors.
- **Cache Fix:** User-Defined `MODULE_CACHE_PATH` must be set to `$(DERIVED_DATA_DIR)/ModuleCache.noindex`.
- **Permission:** InjectionIII REQUIRES "Full Disk Access" to resolve compiler cache crashes.

## 9. AI Integration
- **Provider:** Google Gemini 2.0 Flash.
- **Service:** `GeminiAIService`.
- **Security:** Do NOT hardcode API Keys. Use `ProcessInfo.processInfo.environment` or a secure `Config.plist` that is gitignored.

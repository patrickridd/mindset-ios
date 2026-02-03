# Localization Architecture

## Overview

The Mindset app uses a **hybrid localization strategy** that balances centralization of common strings with feature-specific content ownership.

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         Application Layer                        │
│                                                                  │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌──────────┐ │
│  │FeatureAuth │  │Feature     │  │Feature     │  │Feature   │ │
│  │            │  │Onboarding  │  │Mindset     │  │Dashboard │ │
│  │  View +    │  │            │  │            │  │          │ │
│  │ ViewModel  │  │  View +    │  │  View +    │  │  View +  │ │
│  │            │  │ ViewModel  │  │ ViewModel  │  │ ViewModel│ │
│  └─────┬──────┘  └─────┬──────┘  └─────┬──────┘  └─────┬────┘ │
│        │               │               │               │        │
│        │ import        │ import        │ import        │ import │
│        ↓               ↓               ↓               ↓        │
└────────┼───────────────┼───────────────┼───────────────┼────────┘
         │               │               │               │
    ┌────┴───────────────┴───────────────┴───────────────┴────┐
    │                                                           │
    │              SharedLocalization Package                  │
    │                                                           │
    │  • Common Actions (cancel, save, done, back...)          │
    │  • Error Messages (network error, generic errors...)     │
    │  • Validation (required field, invalid email...)         │
    │  • Auth Terms (sign in, sign out, account...)            │
    │  • Loading States (loading, please wait...)              │
    │  • General UI (settings, help, about...)                 │
    │                                                           │
    │  Type-safe API: SharedLocalizedString.*                  │
    │                                                           │
    └───────────────────────────────────────────────────────────┘

         ↑               ↑               ↑               ↑
         │ uses own      │ uses own      │ uses own      │ uses own
         │ catalog       │ catalog       │ catalog       │ catalog
         │               │               │               │
    ┌────┴──────┐  ┌─────┴──────┐  ┌────┴──────┐  ┌────┴──────┐
    │FeatureAuth│  │Feature     │  │Feature    │  │Feature    │
    │Resources/ │  │Onboarding  │  │Mindset    │  │Dashboard  │
    │Localizable│  │Resources/  │  │Resources/ │  │Resources/ │
    │.xcstrings │  │Localizable │  │Localizable│  │Localizable│
    │           │  │.xcstrings  │  │.xcstrings │  │.xcstrings │
    └───────────┘  └────────────┘  └───────────┘  └───────────┘
```

---

## String Ownership

### SharedLocalization (40+ strings)

**Shared across multiple features:**

| Category | Examples | Use When |
|----------|----------|----------|
| Common Actions | cancel, save, done, back, close | Button labels used everywhere |
| Errors | networkError, somethingWentWrong | Generic error handling |
| Validation | requiredField, invalidEmail | Form validation |
| Auth Terms | signIn, signOut, account | Common auth actions |
| Loading | loading, pleaseWait | Loading states |
| General UI | settings, help, about | App-wide navigation |

### Feature-Specific Catalogs (85+ strings)

**Unique to each feature:**

| Feature | String Count | Examples |
|---------|--------------|----------|
| FeatureAuth | 7 | "Sign in with Apple", auth errors |
| FeatureOnboarding | 15 | Welcome screens, quiz, archetype reveal |
| FeatureMindset | 14 | Ritual prompts, AI reflections, categories |
| FeatureDashboard | 13 | Greetings, streak labels, weekly summaries |
| FeatureHistory | 8 | Empty states, filters, export |
| FeatureSubscription | 18 | Paywall content, features, plans |
| FeatureUserProfile | 10 | Profile stats, subscription status |

---

## Data Flow

### Using SharedLocalization

```
┌─────────────┐
│   View      │
│             │
│ import      │
│ SharedLoc   │
└──────┬──────┘
       │
       │ SharedLocalizedString.cancel
       ↓
┌──────────────────────────────────────┐
│ SharedLocalization.swift             │
│                                      │
│ public static let cancel =           │
│   String(localized: "cancel",        │
│          bundle: .module,            │
│          comment: "Cancel button")   │
└──────┬───────────────────────────────┘
       │
       │ looks up key "cancel"
       ↓
┌──────────────────────────────────────┐
│ SharedLocalization/Resources/        │
│ Localizable.xcstrings                │
│                                      │
│ {                                    │
│   "cancel": {                        │
│     "en": { "value": "Cancel" },     │
│     "es": { "value": "Cancelar" }    │
│   }                                  │
│ }                                    │
└──────────────────────────────────────┘
```

### Using Feature Catalog

```
┌─────────────┐
│   View      │
│  (in        │
│FeatureAuth) │
└──────┬──────┘
       │
       │ String(localized: "auth.signInTitle")
       ↓
┌──────────────────────────────────────┐
│ Swift's String Localization API      │
│ (automatically finds bundle)         │
└──────┬───────────────────────────────┘
       │
       │ looks up key in module's catalog
       ↓
┌──────────────────────────────────────┐
│ FeatureAuth/Resources/               │
│ Localizable.xcstrings                │
│                                      │
│ {                                    │
│   "auth.signInTitle": {              │
│     "en": { "value": "Welcome..." }, │
│     "es": { "value": "Bienvenido"}   │
│   }                                  │
│ }                                    │
└──────────────────────────────────────┘
```

---

## Dependency Graph

```
                    ┌─────────────┐
                    │   Main App  │
                    └──────┬──────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
        ↓                  ↓                  ↓
  ┌──────────┐      ┌──────────┐      ┌──────────┐
  │ Feature  │      │ Feature  │      │ Feature  │
  │  Auth    │      │Onboarding│      │ Mindset  │
  └────┬─────┘      └────┬─────┘      └────┬─────┘
       │                 │                  │
       │ depends on      │ depends on       │ depends on
       │                 │                  │
       └─────────────────┼──────────────────┘
                         │
                         ↓
                ┌────────────────┐
                │  SharedLoc     │
                │  (Package)     │
                │                │
                │  • 40+ strings │
                │  • Type-safe   │
                │  • Bundle res  │
                └────────────────┘

Each Feature also has:
  └─ Resources/Localizable.xcstrings (feature-specific strings)
```

---

## Package Dependency Rules

### ✅ Allowed Dependencies

```
FeatureAuth → SharedLocalization ✓
FeatureOnboarding → SharedLocalization ✓
FeatureMindset → SharedLocalization ✓
All Features → SharedLocalization ✓
```

### ❌ Forbidden Dependencies

```
FeatureAuth → FeatureOnboarding ✗
FeatureMindset → FeatureDashboard ✗
Feature → Feature (any combination) ✗

Reason: Violates modular architecture
Use: FeatureNavigation/MainCoordinator instead
```

### 🔄 Correct Pattern

```
FeatureAuth needs a string that FeatureOnboarding has?

Wrong: Import FeatureOnboarding ✗
Right: Move common string to SharedLocalization ✓
      OR keep it feature-specific and duplicate if needed ✓
```

---

## Translation Workflow

### Phase 1: Development (Current)
```
Developer writes code
   ↓
Add strings to appropriate catalog
   ↓
Use in Views/ViewModels
   ↓
Test in English
```

### Phase 2: Translation (Future)
```
Export .xcstrings files
   ↓
Send to translators
   ↓
Translators add new languages
   ↓
Import translated .xcstrings
   ↓
Test in new languages
```

### Phase 3: Continuous (Maintenance)
```
New feature added
   ↓
New strings added to feature catalog
   ↓
Mark for translation
   ↓
Translators update only new strings
   ↓
Ship updated translations
```

---

## Key Design Decisions

### Why Hybrid (Shared + Feature-Specific)?

**Considered alternatives:**
1. ❌ All strings in one catalog
   - Problem: Features not independent
   - Problem: Merge conflicts
   - Problem: Hard to organize

2. ❌ Only feature-specific catalogs
   - Problem: Duplication of common strings
   - Problem: Inconsistent translations
   - Problem: More work for translators

3. ✅ **Hybrid approach (chosen)**
   - Benefit: No duplication of common strings
   - Benefit: Features stay independent
   - Benefit: Clear ownership
   - Benefit: Scales well

### Why SharedLocalization as a Package?

**Benefits:**
- Type-safe API with compile-time checking
- Clear import statement signals use of common strings
- Can be tested independently
- Follows existing pattern (SharedUI, SharedUtils)
- Easy to audit what's common vs feature-specific

### Why .xcstrings Format?

**Benefits:**
- Native Xcode support
- Version control friendly (JSON)
- Supports pluralization and variations
- Works with Xcode's localization export
- Industry standard for iOS apps

---

## Best Practices

### 1. String Key Naming

**SharedLocalization:**
```swift
// Use PascalCase enums + camelCase properties
SharedLocalizedString.Error.networkError
SharedLocalizedString.Validation.requiredField
```

**Feature Catalogs:**
```
// Use dot notation for hierarchy
"feature.section.element"
"dashboard.greeting.morning"
"ritual.aiReflection.title"
```

### 2. Comments Are Required

```json
{
  "auth.signInTitle": {
    "comment": "Sign in screen title",  ← Always include!
    "localizations": { ... }
  }
}
```

**Why:** Helps translators understand context

### 3. Keep Strings Granular

```
✅ Good: "dashboard.greeting.morning", "dashboard.greeting.afternoon"
❌ Bad: "dashboard.greeting" with parameter for time

Reason: Different languages may have different grammar structures
```

### 4. Use Semantic Keys

```
✅ Good: "ritual.submit" → "Complete Ritual"
❌ Bad: "ritual.button1" → "Complete Ritual"

Reason: Keys should describe purpose, not UI position
```

---

## Testing Strategy

### Unit Tests (SharedLocalization)

```swift
@Test("Common action strings are not empty")
func testCommonActions() {
    #expect(!SharedLocalizedString.cancel.isEmpty)
    #expect(!SharedLocalizedString.save.isEmpty)
}
```

### UI Tests (All Features)

```swift
#Preview {
    MyView()
        .environment(\.locale, Locale(identifier: "es"))
}
```

### Manual Testing

1. Change device language in Settings
2. Launch app
3. Verify all strings appear in target language
4. Check for layout issues (some languages are longer)

---

## Future Enhancements

### Short Term
- [ ] Migrate existing hardcoded strings to catalogs
- [ ] Add more common strings as patterns emerge
- [ ] Create string audit tool

### Medium Term
- [ ] Add Spanish localization
- [ ] Add French localization
- [ ] Implement translation management workflow

### Long Term
- [ ] Add 10+ languages
- [ ] Automated translation updates
- [ ] A/B test different copy variations

---

## Related Documentation

- [LOCALIZATION_GUIDE.md](../guides/LOCALIZATION_GUIDE.md) - Implementation guide
- [LOCALIZATION_EXAMPLES.md](../guides/LOCALIZATION_EXAMPLES.md) - Code examples
- [LOCALIZATION_QUICK_REFERENCE.md](../guides/LOCALIZATION_QUICK_REFERENCE.md) - Cheat sheet
- [Context.md](../../Context.md) - Overall project architecture

---

**Last Updated:** February 2, 2026  
**Status:** ✅ Production Ready

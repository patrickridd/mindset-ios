# Localization Quick Reference

A quick cheat sheet for using the localization system in the Mindset app.

## Import Statement

```swift
import SharedLocalization  // For common strings
```

## Common Actions

```swift
SharedLocalizedString.cancel          // "Cancel"
SharedLocalizedString.save            // "Save"
SharedLocalizedString.done            // "Done"
SharedLocalizedString.back            // "Back"
SharedLocalizedString.close           // "Close"
SharedLocalizedString.continue        // "Continue"
SharedLocalizedString.next            // "Next"
SharedLocalizedString.skip            // "Skip"
SharedLocalizedString.ok              // "OK"
SharedLocalizedString.confirm         // "Confirm"
SharedLocalizedString.delete          // "Delete"
SharedLocalizedString.edit            // "Edit"
SharedLocalizedString.share           // "Share"
SharedLocalizedString.retry           // "Retry"
```

## Error Messages

```swift
SharedLocalizedString.Error.somethingWentWrong      // "Something went wrong"
SharedLocalizedString.Error.networkError            // "Network connection error"
SharedLocalizedString.Error.noInternetConnection    // "No internet connection"
SharedLocalizedString.Error.tryAgain                // "Try again"
SharedLocalizedString.Error.pleaseTryAgainLater     // "Please try again later"
SharedLocalizedString.Error.loadingFailed           // "Failed to load content"
SharedLocalizedString.Error.saveFailed              // "Failed to save"
```

## Validation

```swift
SharedLocalizedString.Validation.requiredField      // "This field is required"
SharedLocalizedString.Validation.invalidEmail       // "Invalid email address"
SharedLocalizedString.Validation.tooShort           // "Input is too short"
SharedLocalizedString.Validation.tooLong            // "Input is too long"
```

## Auth (Common Terms)

```swift
SharedLocalizedString.Auth.signIn       // "Sign In"
SharedLocalizedString.Auth.signOut      // "Sign Out"
SharedLocalizedString.Auth.account      // "Account"
SharedLocalizedString.Auth.profile      // "Profile"
```

## Loading States

```swift
SharedLocalizedString.Loading.loading       // "Loading..."
SharedLocalizedString.Loading.pleaseWait    // "Please wait"
SharedLocalizedString.Loading.processing    // "Processing..."
```

## General UI

```swift
SharedLocalizedString.General.settings      // "Settings"
SharedLocalizedString.General.help          // "Help"
SharedLocalizedString.General.about         // "About"
SharedLocalizedString.General.version       // "Version"
SharedLocalizedString.General.feedback      // "Feedback"
SharedLocalizedString.General.contactUs     // "Contact Us"
```

## Feature-Specific Strings

```swift
// Use String(localized:) for feature-specific content
Text(String(localized: "ritual.title"))
Text(String(localized: "dashboard.greeting.morning"))
Text(String(localized: "onboarding.welcome.title"))

// With parameters/interpolation
Text(String(localized: "dashboard.streak.days", 
           defaultValue: "\(count) days"))
```

## Usage Patterns

### Button with Common Action

```swift
Button {
    dismiss()
} label: {
    Text(SharedLocalizedString.cancel)
}
```

### Error Display

```swift
if let error = viewModel.error {
    Text(SharedLocalizedString.Error.somethingWentWrong)
    Button(SharedLocalizedString.retry) {
        viewModel.retry()
    }
}
```

### Loading State

```swift
if viewModel.isLoading {
    ProgressView()
    Text(SharedLocalizedString.Loading.loading)
}
```

### Form Validation

```swift
if emailError {
    Text(SharedLocalizedString.Validation.invalidEmail)
        .foregroundStyle(.red)
}
```

### Navigation Title (Feature-Specific)

```swift
.navigationTitle(String(localized: "dashboard.title"))
```

## Decision Tree

**Use SharedLocalization when:**
- ✅ The string appears in multiple features
- ✅ It's a common UI action (Cancel, Save, Done, etc.)
- ✅ It's a generic error message
- ✅ It's standard validation text
- ✅ It's a common auth term

**Use Feature String Catalog when:**
- ✅ The string is unique to one feature
- ✅ It's a screen title or prompt
- ✅ It's feature-specific content
- ✅ It's part of the feature's domain language

## File Locations

```
Packages/
├── SharedLocalization/
│   └── Sources/SharedLocalization/Resources/
│       └── Localizable.xcstrings
│
├── FeatureAuth/Sources/FeatureAuth/Resources/
│   └── Localizable.xcstrings
│
├── FeatureOnboarding/Sources/FeatureOnboarding/Resources/
│   └── Localizable.xcstrings
│
├── FeatureMindset/Sources/FeatureMindset/Resources/
│   └── Localizable.xcstrings
│
├── FeatureDashboard/Sources/FeatureDashboard/Resources/
│   └── Localizable.xcstrings
│
├── FeatureHistory/Sources/FeatureHistory/Resources/
│   └── Localizable.xcstrings
│
├── FeatureSubscription/Sources/FeatureSubscription/Resources/
│   └── Localizable.xcstrings
│
└── FeatureUserProfile/Sources/FeatureUserProfile/Resources/
    └── Localizable.xcstrings
```

## Common Mistakes to Avoid

❌ **Don't hardcode strings:**
```swift
Text("Cancel")  // BAD
```

✅ **Use localization:**
```swift
Text(SharedLocalizedString.cancel)  // GOOD
```

---

❌ **Don't duplicate common strings in feature catalogs:**
```json
// In FeatureAuth/Resources/Localizable.xcstrings - BAD
{
  "cancel": { "value": "Cancel" }  // This belongs in SharedLocalization!
}
```

✅ **Use SharedLocalization for common strings:**
```swift
Text(SharedLocalizedString.cancel)  // GOOD
```

---

❌ **Don't forget to import SharedLocalization:**
```swift
// Will cause compile error
Text(SharedLocalizedString.save)
```

✅ **Import at the top:**
```swift
import SharedLocalization

Text(SharedLocalizedString.save)  // GOOD
```

---

❌ **Don't use SharedLocalization for feature-specific content:**
```swift
// Don't add "ritual.title" to SharedLocalization
```

✅ **Use feature catalogs for feature content:**
```swift
Text(String(localized: "ritual.title"))  // GOOD
```

## Testing

### Test Different Languages

```swift
#Preview {
    MyView()
        .environment(\.locale, Locale(identifier: "es"))  // Spanish
}
```

### Test Missing Keys

If a key is missing, you'll see the key name displayed in the UI:
```
"dashboard.streak.title"  // Key is missing from catalog
```

## Adding New Strings

### To SharedLocalization:

1. Open `SharedLocalization/Sources/SharedLocalization/SharedLocalization.swift`
2. Add to the appropriate enum:
```swift
public enum General {
    public static let myNewString = String(localized: "general.myNewString", bundle: .module, comment: "Description")
}
```
3. Add to `Localizable.xcstrings` in the same package

### To Feature Catalog:

1. Open `Feature[Name]/Sources/Feature[Name]/Resources/Localizable.xcstrings`
2. Add your key:
```json
{
  "myFeature.myKey": {
    "comment": "Description",
    "extractionState": "manual",
    "localizations": {
      "en": {
        "stringUnit": {
          "state": "translated",
          "value": "My English text"
        }
      }
    }
  }
}
```
3. Use in code: `String(localized: "myFeature.myKey")`

## Resources

- [Full Localization Guide](./LOCALIZATION_GUIDE.md)
- [Real-World Examples](./LOCALIZATION_EXAMPLES.md)
- [Apple's Localization Documentation](https://developer.apple.com/documentation/xcode/localizing-your-app)

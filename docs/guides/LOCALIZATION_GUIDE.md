# Localization Guide

## Overview

The Mindset app uses a **hybrid localization strategy** that balances modularity with practical string management:

- **SharedLocalization**: Common strings used across multiple features (buttons, errors, validation)
- **Feature-specific catalogs**: Each Feature module has its own `Localizable.xcstrings` for feature-specific content

This approach aligns with our modular architecture and scales well as the app grows.

## Architecture

```
SharedLocalization (Package)
├── Common actions: cancel, save, done, continue, etc.
├── Error messages: network errors, generic errors
├── Validation: required fields, invalid input
└── Auth terms: sign in, sign out, account

FeatureAuth/Resources/Localizable.xcstrings
├── Sign in with Apple button
├── Sign in with Google button
└── Auth-specific error messages

FeatureOnboarding/Resources/Localizable.xcstrings
├── Welcome screens
├── Quiz questions
├── Archetype reveal content
└── Pain screens

FeatureMindset/Resources/Localizable.xcstrings
├── Ritual prompts
├── AI reflection labels
├── Prompt categories
└── Success messages

FeatureDashboard/Resources/Localizable.xcstrings
├── Dashboard greetings
├── Streak labels
├── XP messages
└── Weekly summaries

FeatureHistory/Resources/Localizable.xcstrings
├── History filters
├── Empty states
└── Export options

FeatureSubscription/Resources/Localizable.xcstrings
├── Paywall content
├── Feature descriptions
├── Plan names
└── Pricing labels

FeatureUserProfile/Resources/Localizable.xcstrings
├── Profile stats
├── Subscription status
└── Preferences
```

## Usage Examples

### 1. Using SharedLocalization (Common Strings)

Import `SharedLocalization` at the top of your View or ViewModel:

```swift
import SwiftUI
import SharedLocalization

struct MyView: View {
    var body: some View {
        VStack {
            // Common buttons
            Button(SharedLocalizedString.cancel) {
                dismiss()
            }
            
            Button(SharedLocalizedString.save) {
                saveData()
            }
            
            // Error messages
            if let error = viewModel.error {
                Text(SharedLocalizedString.Error.somethingWentWrong)
                    .foregroundColor(.red)
                
                Button(SharedLocalizedString.retry) {
                    viewModel.retryAction()
                }
            }
            
            // Loading states
            if viewModel.isLoading {
                ProgressView()
                Text(SharedLocalizedString.Loading.loading)
            }
        }
    }
}
```

**Available SharedLocalization categories:**

```swift
// Common Actions
SharedLocalizedString.cancel
SharedLocalizedString.save
SharedLocalizedString.done
SharedLocalizedString.back
SharedLocalizedString.close
SharedLocalizedString.continue
SharedLocalizedString.next
SharedLocalizedString.skip
SharedLocalizedString.ok
SharedLocalizedString.confirm
SharedLocalizedString.delete
SharedLocalizedString.edit
SharedLocalizedString.share
SharedLocalizedString.retry

// Error Messages
SharedLocalizedString.Error.somethingWentWrong
SharedLocalizedString.Error.networkError
SharedLocalizedString.Error.noInternetConnection
SharedLocalizedString.Error.tryAgain
SharedLocalizedString.Error.pleaseTryAgainLater
SharedLocalizedString.Error.loadingFailed
SharedLocalizedString.Error.saveFailed

// Validation
SharedLocalizedString.Validation.requiredField
SharedLocalizedString.Validation.invalidEmail
SharedLocalizedString.Validation.tooShort
SharedLocalizedString.Validation.tooLong

// Auth (Common Terms)
SharedLocalizedString.Auth.signIn
SharedLocalizedString.Auth.signOut
SharedLocalizedString.Auth.account
SharedLocalizedString.Auth.profile

// Loading States
SharedLocalizedString.Loading.loading
SharedLocalizedString.Loading.pleaseWait
SharedLocalizedString.Loading.processing

// General UI
SharedLocalizedString.General.settings
SharedLocalizedString.General.help
SharedLocalizedString.General.about
SharedLocalizedString.General.version
SharedLocalizedString.General.feedback
SharedLocalizedString.General.contactUs
```

### 2. Using Feature-Specific Strings

For feature-specific content, use the standard `String(localized:)` API:

```swift
import SwiftUI

struct MorningRitualView: View {
    var body: some View {
        VStack {
            // Feature-specific strings use String(localized:)
            Text(String(localized: "ritual.title"))
                .font(MindsetFonts.displayHeadline)
            
            Text(String(localized: "ritual.promptLabel"))
                .font(MindsetFonts.label)
            
            TextEditor(text: $response)
                .placeholder(String(localized: "ritual.placeholder"))
            
            Button(String(localized: "ritual.submit")) {
                submitRitual()
            }
        }
    }
}
```

### 3. ViewModels and Localization

ViewModels can expose localized strings for the View to use:

```swift
import Foundation
import Domain
import SharedLocalization

@Observable
final class SignInViewModel {
    var errorMessage: String?
    var isLoading: Bool = false
    
    func signIn() async {
        isLoading = true
        
        do {
            try await authService.signIn()
            isLoading = false
        } catch {
            isLoading = false
            // Use SharedLocalization for common errors
            errorMessage = SharedLocalizedString.Error.somethingWentWrong
            // Or feature-specific error
            errorMessage = String(localized: "auth.error.signInFailed")
        }
    }
}
```

### 4. String Interpolation and Parameters

For strings with parameters (like counts or names), use the standard localization format:

**In Localizable.xcstrings:**
```json
{
  "dashboard.streak.days" : {
    "comment" : "Days count for streak",
    "localizations" : {
      "en" : {
        "stringUnit" : {
          "state" : "translated",
          "value" : "%lld days"
        }
      }
    }
  }
}
```

**In Swift:**
```swift
let streakCount = 7
Text(String(localized: "dashboard.streak.days", defaultValue: "\(streakCount) days"))
// Output: "7 days"
```

### 5. Best Practices

#### When to use SharedLocalization vs Feature-specific:

**Use SharedLocalization for:**
- Common UI actions (Cancel, Save, Done, Back, Close)
- Generic error messages (Something went wrong, Network error)
- Standard validation messages (Required field, Invalid email)
- Common auth terms (Sign In, Sign Out, Account)
- Loading states (Loading..., Please wait)

**Use Feature-specific catalogs for:**
- Screen titles specific to a feature
- Feature-specific error messages
- Prompt questions and categories
- Feature-specific labels and descriptions
- Any content unique to that feature

#### Naming Conventions:

**SharedLocalization:**
- Use camelCase for keys (e.g., `cancel`, `save`, `done`)
- Group related strings in nested enums (e.g., `Error.`, `Validation.`, `Auth.`)

**Feature catalogs:**
- Use dot notation for organization (e.g., `ritual.title`, `dashboard.greeting.morning`)
- Group by screen or component (e.g., `onboarding.welcome.*`, `paywall.feature.*`)
- Use descriptive names that indicate context

#### Comments:

Always include clear comments in your xcstrings files:

```json
{
  "auth.signInWithApple" : {
    "comment" : "Sign in with Apple button",
    "extractionState" : "manual",
    "localizations" : {
      "en" : {
        "stringUnit" : {
          "state" : "translated",
          "value" : "Sign in with Apple"
        }
      }
    }
  }
}
```

## Adding New Languages

When you're ready to add a new language (e.g., Spanish):

1. In Xcode, select the `.xcstrings` file
2. Click the `+` button in the inspector
3. Select the language (e.g., Spanish)
4. Xcode will create the new localization keys
5. Translate the values for each key

**Example with Spanish:**
```json
{
  "cancel" : {
    "comment" : "Cancel button",
    "localizations" : {
      "en" : {
        "stringUnit" : {
          "state" : "translated",
          "value" : "Cancel"
        }
      },
      "es" : {
        "stringUnit" : {
          "state" : "translated",
          "value" : "Cancelar"
        }
      }
    }
  }
}
```

## Testing Localization

### Preview with Different Languages

```swift
#Preview {
    MorningRitualView()
        .environment(\.locale, Locale(identifier: "es"))
}
```

### Test in Simulator

1. Open Settings app
2. Go to General → Language & Region
3. Add a new language
4. Set it as primary
5. Launch your app

## Migration Strategy

If you have existing hardcoded strings:

1. **Identify the string's scope:**
   - Is it used in multiple features? → Add to SharedLocalization
   - Is it feature-specific? → Add to that feature's catalog

2. **Add to the appropriate catalog:**
   ```json
   {
     "myKey" : {
       "comment" : "Description",
       "extractionState" : "manual",
       "localizations" : {
         "en" : {
           "stringUnit" : {
             "state" : "translated",
             "value" : "Your English text"
           }
         }
       }
     }
   }
   ```

3. **Replace the hardcoded string:**
   ```swift
   // Before
   Text("Cancel")
   
   // After (if common)
   Text(SharedLocalizedString.cancel)
   
   // Or (if feature-specific)
   Text(String(localized: "myKey"))
   ```

## Summary

- **SharedLocalization**: Import and use `SharedLocalizedString.*` for common strings
- **Feature catalogs**: Use `String(localized: "key")` for feature-specific content
- **Keep it organized**: Group related strings with dot notation
- **Document everything**: Add clear comments to help translators
- **Test thoroughly**: Use Xcode previews and simulator language settings

This hybrid approach gives you the benefits of:
- ✅ No duplication of common strings
- ✅ Feature independence and scalability
- ✅ Clear ownership and organization
- ✅ Easy translation workflow
- ✅ Consistent with your modular architecture

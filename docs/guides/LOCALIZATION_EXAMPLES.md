# Localization Examples

This guide shows real-world examples of using the localization system in different scenarios.

## Example 1: SignInView (Mixing Shared + Feature Strings)

```swift
import SwiftUI
import AuthenticationServices
import SharedUI
import SharedUtils
import SharedLocalization  // ← Import for common strings
import Domain

public struct SignInView: View {
    @State private var viewModel: SignInViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    public var body: some View {
        ZStack {
            // Background gradient...
            
            ScrollView {
                VStack(spacing: MindsetLayout.spacing12) {
                    // Hero Icon...
                    
                    // Title - Feature-specific, type-safe!
                    Text(FeatureAuthStrings.signInTitle)
                        .font(MindsetFonts.displayHeadline)
                        .foregroundStyle(MindsetColors.textPrimary)
                    
                    // Subtitle - Feature-specific, type-safe!
                    Text(FeatureAuthStrings.signInSubtitle)
                        .font(MindsetFonts.body)
                        .foregroundStyle(MindsetColors.textSecondary)
                    
                    // Sign in with Apple Button - Feature-specific
                    SignInWithAppleButton { /* ... */ }
                        .accessibilityLabel(FeatureAuthStrings.signInWithApple)
                    
                    // Google Sign In Button - Feature-specific
                    GoogleSignInButton { /* ... */ }
                    
                    // Continue without account - Feature-specific
                    Button {
                        HapticManager.selection()
                        Task {
                            await viewModel.continueWithoutAccount()
                        }
                    } label: {
                        Text(FeatureAuthStrings.continueAsGuest)
                            .font(MindsetFonts.button)
                    }
                }
            }
            
            // Loading overlay - SharedLocalization
            if viewModel.isSigningIn {
                loadingOverlay
            }
            
            // Error alert - Mix of both
            if let errorMessage = viewModel.errorMessage {
                errorAlert(message: errorMessage)
            }
        }
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.6)
            
            VStack(spacing: MindsetLayout.spacing20) {
                ProgressView()
                
                // Use SharedLocalization for common loading state
                Text(SharedLocalizedString.Loading.pleaseWait)
                    .font(MindsetFonts.button)
            }
        }
    }
    
    private func errorAlert(message: String) -> some View {
        VStack(spacing: MindsetLayout.spacing16) {
            Image(systemName: "exclamationmark.triangle.fill")
            
            // Feature-specific error title - type-safe!
            Text(FeatureAuthStrings.Error.signInFailed)
                .font(MindsetFonts.featureTitle)
            
            Text(message)
                .font(MindsetFonts.body)
            
            // SharedLocalization for common "Try Again" button
            Button {
                viewModel.dismissError()
            } label: {
                Text(SharedLocalizedString.retry)
                    .font(MindsetFonts.button)
            }
        }
    }
}
```

**Key Benefits:**
- ✅ **Compile-time safety** - Typos caught at build time
- ✅ **Autocomplete** - Xcode suggests available strings
- ✅ **Refactoring support** - Rename safely with Xcode
- ✅ **No magic strings** - Clear, discoverable API

---

## Example 2: DashboardView (Heavy Use of Feature Strings)

```swift
import SwiftUI
import SharedUI
import SharedLocalization
import Domain

struct DashboardView: View {
    @State private var viewModel: DashboardViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: MindsetLayout.spacing20) {
                    // Dynamic greeting based on time of day
                    Text(greetingText)
                        .font(MindsetFonts.displayLarge)
                    
                    // Streak Card - Type-safe strings!
                    VStack {
                        Text(FeatureDashboardStrings.Streak.title)
                            .font(MindsetFonts.label)
                        
                        // String interpolation with count
                        Text(String(localized: "dashboard.streak.days", 
                                   defaultValue: "\(viewModel.currentStreak) days"))
                            .font(MindsetFonts.statValue)
                    }
                    
                    // XP Card - Type-safe!
                    VStack {
                        Text(FeatureDashboardStrings.XP.title)
                            .font(MindsetFonts.label)
                        
                        Text("\(viewModel.totalXP)")
                            .font(MindsetFonts.statValue)
                    }
                    
                    // Today's Ritual Status
                    ritualStatusCard
                    
                    // Weekly Summary
                    weeklySummaryCard
                }
                .padding()
            }
            .navigationTitle(FeatureDashboardStrings.title)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSettings()
                    } label: {
                        // SharedLocalization for common settings label
                        Label(SharedLocalizedString.General.settings, 
                              systemImage: "gearshape")
                    }
                }
            }
        }
    }
    
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            return FeatureDashboardStrings.Greeting.morning
        case 12..<17:
            return FeatureDashboardStrings.Greeting.afternoon
        default:
            return FeatureDashboardStrings.Greeting.evening
        }
    }
    
    private var ritualStatusCard: some View {
        VStack(alignment: .leading, spacing: MindsetLayout.spacing12) {
            Text(FeatureDashboardStrings.TodayRitual.title)
                .font(MindsetFonts.label)
            
            if viewModel.hasTodayRitualCompleted {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text(FeatureDashboardStrings.TodayRitual.completed)
                }
                .foregroundStyle(MindsetColors.successGreen)
            } else {
                Button {
                    startRitual()
                } label: {
                    Text(FeatureDashboardStrings.TodayRitual.pending)
                        .font(MindsetFonts.button)
                }
            }
        }
        .padding(MindsetLayout.paddingCard)
        .background(
            RoundedRectangle(cornerRadius: MindsetLayout.radiusCard)
                .fill(MindsetColors.backgroundSecondary(for: colorScheme))
        )
    }
    
    private var weeklySummaryCard: some View {
        VStack(alignment: .leading, spacing: MindsetLayout.spacing12) {
            Text(FeatureDashboardStrings.WeeklySummary.title)
                .font(MindsetFonts.label)
            
            Text(String(localized: "dashboard.weeklySummary.ritualsCompleted",
                       defaultValue: "\(viewModel.weeklyRitualCount) rituals completed"))
                .font(MindsetFonts.body)
        }
    }
}
```

---

## Example 3: ViewModel with Error Handling

```swift
import Foundation
import Domain
import SharedLocalization

@Observable
final class MorningRitualViewModel {
    var currentPrompt: MindsetPrompt?
    var userResponse: String = ""
    var errorMessage: String?
    var isSubmitting: Bool = false
    var aiReflection: String?
    
    private let addMindsetUseCase: AddMindsetUseCase
    
    func submitRitual() async {
        // Validate input
        guard !userResponse.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            // Feature-specific validation error - type-safe!
            errorMessage = FeatureMindsetStrings.Error.emptyResponse
            return
        }
        
        isSubmitting = true
        
        do {
            let entry = MindsetEntry(/* ... */)
            try await addMindsetUseCase.execute(entry)
            isSubmitting = false
            // Success - no error
            errorMessage = nil
        } catch {
            isSubmitting = false
            
            // Determine appropriate error message
            if let domainError = error as? DomainError {
                switch domainError {
                case .networkError:
                    // Use SharedLocalization for common network error
                    errorMessage = SharedLocalizedString.Error.networkError
                case .saveFailed:
                    errorMessage = SharedLocalizedString.Error.saveFailed
                default:
                    errorMessage = SharedLocalizedString.Error.somethingWentWrong
                }
            } else {
                // Generic fallback
                errorMessage = SharedLocalizedString.Error.somethingWentWrong
            }
        }
    }
}
```

---

## Example 4: Form Validation

```swift
import SwiftUI
import SharedUI
import SharedLocalization

struct ProfileEditView: View {
    @State private var email: String = ""
    @State private var emailError: String?
    
    var body: some View {
        Form {
            Section {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .onChange(of: email) { _, newValue in
                        validateEmail(newValue)
                    }
                
                if let error = emailError {
                    Text(error)
                        .font(MindsetFonts.caption)
                        .foregroundStyle(.red)
                }
            }
            
            Section {
                Button {
                    saveProfile()
                } label: {
                    // SharedLocalization for common Save button
                    Text(SharedLocalizedString.save)
                }
                
                Button(role: .cancel) {
                    dismiss()
                } label: {
                    // SharedLocalization for common Cancel button
                    Text(SharedLocalizedString.cancel)
                }
            }
        }
    }
    
    private func validateEmail(_ email: String) {
        // Empty check
        guard !email.isEmpty else {
            emailError = SharedLocalizedString.Validation.requiredField
            return
        }
        
        // Format check
        guard email.contains("@") && email.contains(".") else {
            emailError = SharedLocalizedString.Validation.invalidEmail
            return
        }
        
        // Valid
        emailError = nil
    }
}
```

---

## Example 5: Paywall with Features List

```swift
import SwiftUI
import SharedUI
import SharedLocalization

struct PaywallView: View {
    @State private var selectedPlan: SubscriptionPlan?
    
    var body: some View {
        ScrollView {
            VStack(spacing: MindsetLayout.spacing20) {
                // Header
                VStack(spacing: MindsetLayout.spacing8) {
                    Text(String(localized: "paywall.title"))
                        .font(MindsetFonts.displayHeadline)
                    
                    Text(String(localized: "paywall.subtitle"))
                        .font(MindsetFonts.body)
                }
                
                // Features
                VStack(alignment: .leading, spacing: MindsetLayout.spacing12) {
                    featureRow(String(localized: "paywall.feature.aiCoach"))
                    featureRow(String(localized: "paywall.feature.unlimitedRituals"))
                    featureRow(String(localized: "paywall.feature.curatedPrompts"))
                    featureRow(String(localized: "paywall.feature.streakTracking"))
                    featureRow(String(localized: "paywall.feature.weeklySummaries"))
                    featureRow(String(localized: "paywall.feature.cloudSync"))
                }
                
                // Plans
                VStack(spacing: MindsetLayout.spacing12) {
                    planCard(
                        title: String(localized: "paywall.plan.yearly.title"),
                        badge: String(localized: "paywall.plan.yearly.badge"),
                        price: "$59.99/year"
                    )
                    
                    planCard(
                        title: String(localized: "paywall.plan.monthly.title"),
                        badge: nil,
                        price: "$9.99/month"
                    )
                }
                
                // CTA
                Button {
                    subscribe()
                } label: {
                    Text(String(localized: "paywall.cta.subscribe"))
                        .font(MindsetFonts.button)
                        .frame(maxWidth: .infinity)
                        .frame(height: MindsetLayout.buttonHeight)
                }
                
                // Footer links
                HStack(spacing: MindsetLayout.spacing16) {
                    Button(String(localized: "paywall.terms")) {
                        showTerms()
                    }
                    
                    Button(String(localized: "paywall.privacy")) {
                        showPrivacy()
                    }
                    
                    Button(String(localized: "paywall.restore")) {
                        restorePurchases()
                    }
                }
                .font(MindsetFonts.caption)
            }
        }
    }
    
    private func featureRow(_ text: String) -> some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(MindsetColors.successGreen)
            Text(text)
                .font(MindsetFonts.body)
        }
    }
}
```

---

## Example 6: Empty State View

```swift
import SwiftUI
import SharedUI
import SharedLocalization

struct HistoryEmptyStateView: View {
    let onStartRitual: () -> Void
    
    var body: some View {
        VStack(spacing: MindsetLayout.spacing20) {
            Image(systemName: "book.closed")
                .font(.system(size: 80))
                .foregroundStyle(MindsetColors.textSecondary)
            
            VStack(spacing: MindsetLayout.spacing8) {
                // Feature-specific empty state title
                Text(String(localized: "history.empty.title"))
                    .font(MindsetFonts.title2)
                    .foregroundStyle(MindsetColors.textPrimary)
                
                // Feature-specific empty state message
                Text(String(localized: "history.empty.message"))
                    .font(MindsetFonts.body)
                    .foregroundStyle(MindsetColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                HapticManager.action()
                onStartRitual()
            } label: {
                // SharedLocalization for common action
                Text(SharedLocalizedString.continue)
                    .font(MindsetFonts.button)
            }
        }
        .padding()
    }
}
```

---

## Key Takeaways

1. **Import SharedLocalization** when you need common strings
2. **Use `SharedLocalizedString.*`** for buttons, errors, validation
3. **Use `Feature[Name]Strings.*`** for feature-specific content - **NO magic strings!**
4. **Mix both approaches** in the same view when appropriate
5. **Keep ViewModels clean** - return localized strings from ViewModel, let View display them
6. **String interpolation** - use `defaultValue:` parameter for strings with variables
7. **Accessibility** - localized strings work automatically with VoiceOver

This pattern ensures:
- ✅ No duplication of common strings
- ✅ Feature independence
- ✅ **Compile-time safety** - no magic strings, typos caught at build time
- ✅ **Autocomplete support** - Xcode shows available strings
- ✅ **Refactoring friendly** - rename safely across the codebase
- ✅ Easy to maintain and translate
- ✅ Consistent with your modular architecture

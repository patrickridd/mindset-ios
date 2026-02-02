# ✅ Decoupled Auth Architecture - Provider-Agnostic Design

## The Problem You Identified

**Original Design (Coupled to Providers):**
```swift
// ❌ Domain layer knows about Apple, Google, etc.
protocol AuthService {
    func signInWithApple(...) async throws -> String
    func signInWithGoogle(...) async throws -> String
    func signInWithFacebook(...) async throws -> String  // What if we add more?
}
```

**Issues:**
1. Domain layer is coupled to specific auth providers (Apple, Google)
2. Adding a new provider requires changing the Domain protocol
3. Domain should define generic contracts, not implementation details
4. Violates Open/Closed Principle (open for extension, closed for modification)

## The Solution: Generic Credential Types

**New Design (Provider-Agnostic):**
```swift
// ✅ Domain defines generic credential types
public enum AuthCredential {
    case oauth(identityToken: String, nonce: String?, accessToken: String?, fullName: String?)
    case email(email: String, password: String)
    case anonymous
}

protocol AuthService {
    func signIn(with credential: AuthCredential) async throws -> String
    // ... other methods
}
```

**Benefits:**
1. ✅ Domain has zero knowledge of Apple, Google, Facebook, etc.
2. ✅ Adding a new provider (Twitter, Microsoft) doesn't change the protocol
3. ✅ Data layer decides how to interpret credentials (Firebase, Supabase, custom)
4. ✅ Follows clean architecture principles
5. ✅ Extensible without breaking existing code

## Architecture Layers

### Domain Layer (Generic Contracts)

**`AuthCredential` enum** - Defines credential structure without coupling to providers:

```swift
public enum AuthCredential: Sendable {
    /// OAuth credential (Apple, Google, Twitter, Microsoft, etc.)
    case oauth(
        identityToken: String,
        nonce: String? = nil,        // Apple uses this
        accessToken: String? = nil,   // Google uses this
        fullName: String? = nil
    )
    
    /// Email/password credential
    case email(email: String, password: String)
    
    /// Anonymous credential for trials
    case anonymous
}
```

**`AuthService` protocol** - Generic interface:

```swift
public protocol AuthService: Sendable {
    func signIn(with credential: AuthCredential) async throws -> String
    func getCurrentUserID() async -> String?
    func signOut() async throws
    func isAuthenticated() async -> Bool
}
```

### Data Layer (Implementation Details)

**`FirebaseAuthService`** - Interprets credentials and maps to Firebase:

```swift
public func signIn(with credential: AuthCredential) async throws -> String {
    switch credential {
    case .oauth(let idToken, let nonce, let accessToken, let fullName):
        // Determine provider based on presence of nonce (Apple) or accessToken (Google)
        if let nonce = nonce {
            // Apple Sign In
            let cred = OAuthProvider.credential(providerID: .apple, idToken: idToken, rawNonce: nonce)
            return try await Auth.auth().signIn(with: cred).user.uid
        } else if let accessToken = accessToken {
            // Google Sign In
            let cred = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            return try await Auth.auth().signIn(with: cred).user.uid
        }
        
    case .email(let email, let password):
        return try await Auth.auth().signIn(withEmail: email, password: password).user.uid
        
    case .anonymous:
        return try await Auth.auth().signInAnonymously().user.uid
    }
}
```

**Key Insight:** The Data layer knows about Firebase, Apple, and Google. The Domain layer doesn't!

### Feature Layer (UI Logic)

**`SignInViewModel`** - Uses generic credentials:

```swift
// Apple Sign In
let credential = AuthCredential.oauth(
    identityToken: appleToken,
    nonce: secureNonce,      // Apple-specific
    accessToken: nil,
    fullName: "John Doe"
)
let userID = try await authService.signIn(with: credential)

// Google Sign In
let credential = AuthCredential.oauth(
    identityToken: googleIdToken,
    nonce: nil,
    accessToken: googleAccessToken,  // Google-specific
    fullName: nil
)
let userID = try await authService.signIn(with: credential)

// Anonymous
let credential = AuthCredential.anonymous
let userID = try await authService.signIn(with: credential)
```

## Adding New Providers

### Example: Microsoft Sign In

**No changes to Domain layer required!** Just use the existing `oauth` credential:

```swift
// In ViewModel (Feature layer)
func signInWithMicrosoft(token: String) async {
    let credential = AuthCredential.oauth(
        identityToken: token,
        nonce: nil,
        accessToken: nil,
        fullName: nil
    )
    
    let userID = try await authService.signIn(with: credential)
}
```

**In Data layer,** add Microsoft handling to `FirebaseAuthService`:

```swift
// In FirebaseAuthService
case .oauth(let idToken, let nonce, let accessToken, _):
    if let nonce = nonce {
        // Apple
    } else if let accessToken = accessToken {
        // Google
    } else {
        // Microsoft (or any other OAuth provider)
        let cred = OAuthProvider.credential(providerID: "microsoft.com", idToken: idToken)
        return try await Auth.auth().signIn(with: cred).user.uid
    }
```

### Example: Phone Auth

If you need phone auth in the future, just extend the enum:

```swift
public enum AuthCredential: Sendable {
    case oauth(...)
    case email(...)
    case anonymous
    case phone(phoneNumber: String, verificationCode: String)  // New!
}
```

Then handle it in `FirebaseAuthService`:

```swift
case .phone(let number, let code):
    let credential = PhoneAuthProvider.provider().credential(
        withVerificationID: number,
        verificationCode: code
    )
    return try await Auth.auth().signIn(with: credential).user.uid
```

## Comparison: Before vs. After

### Before (Provider-Coupled)

```
Domain Layer (knows about Apple, Google):
┌─────────────────────────────────────────┐
│ protocol AuthService {                  │
│   func signInWithApple(...) ❌          │
│   func signInWithGoogle(...) ❌         │
│   func signInWithFacebook(...) ❌       │
│ }                                       │
└─────────────────────────────────────────┘
          ▲
          │ Adding Twitter? Must change protocol!
          │
Data Layer (implements provider-specific methods)
```

### After (Provider-Agnostic)

```
Domain Layer (generic credentials):
┌─────────────────────────────────────────┐
│ enum AuthCredential { ✅                │
│   case oauth(...)                       │
│   case email(...)                       │
│   case anonymous                        │
│ }                                       │
│                                         │
│ protocol AuthService {                  │
│   func signIn(with: AuthCredential) ✅  │
│ }                                       │
└─────────────────────────────────────────┘
          ▲
          │ Adding Twitter? Just pass oauth credential!
          │
Data Layer (interprets credentials for Firebase)
┌─────────────────────────────────────────┐
│ switch credential {                     │
│   case .oauth:                          │
│     if nonce → Apple                    │
│     if accessToken → Google             │
│     else → Microsoft/Twitter/etc.       │
│ }                                       │
└─────────────────────────────────────────┘
```

## Real-World Example: Switching from Firebase to Supabase

With the new architecture, switching auth providers is trivial:

**Step 1:** Create `SupabaseAuthService` (implements `AuthService` protocol)

```swift
import Domain
import Supabase

public final class SupabaseAuthService: AuthService {
    private let client: SupabaseClient
    
    public func signIn(with credential: AuthCredential) async throws -> String {
        switch credential {
        case .oauth(let idToken, _, _, _):
            // Supabase handles OAuth differently than Firebase
            let session = try await client.auth.signIn(
                withIdToken: idToken,
                provider: .apple  // or .google
            )
            return session.user.id
            
        case .email(let email, let password):
            let session = try await client.auth.signIn(email: email, password: password)
            return session.user.id
            
        case .anonymous:
            let session = try await client.auth.signInAnonymously()
            return session.user.id
        }
    }
}
```

**Step 2:** Inject `SupabaseAuthService` instead of `FirebaseAuthService`

```swift
// Before
let authService = FirebaseAuthService()

// After (no other code changes needed!)
let authService = SupabaseAuthService()

let viewModel = SignInViewModel(authService: authService, ...)
```

**No changes needed in:**
- ✅ Domain layer (protocol unchanged)
- ✅ FeatureAuth layer (ViewModel unchanged)
- ✅ UI layer (SignInView unchanged)
- ✅ Tests (use MockAuthService)

## Testing Benefits

**Mock is provider-agnostic:**

```swift
let mockAuth = MockAuthService()

// Test Apple Sign In
await viewModel.signInWithApple(...)
#expect(mockAuth.lastCredential case .oauth(nonce: "..."))

// Test Google Sign In
await viewModel.signInWithGoogle(...)
#expect(mockAuth.lastCredential case .oauth(accessToken: "..."))

// Test Anonymous
await viewModel.continueWithoutAccount()
#expect(mockAuth.lastCredential case .anonymous)
```

You're testing ViewModel logic, not Firebase implementation details!

## Summary

### What Changed

| Aspect | Before | After |
|--------|--------|-------|
| **Domain Layer** | `signInWithApple`, `signInWithGoogle` ❌ | `signIn(with: AuthCredential)` ✅ |
| **Coupling** | Coupled to Apple, Google names | Decoupled via generic credentials |
| **Extensibility** | Add method per provider | Reuse existing credential types |
| **Provider Knowledge** | Domain knows providers | Only Data layer knows providers |
| **Clean Architecture** | Violated (leaky abstraction) | Preserved (proper boundaries) |

### Why This Matters

1. **Domain Stability** - Adding auth providers doesn't change Domain layer
2. **Provider Flexibility** - Switch from Firebase to Supabase with minimal changes
3. **Testing** - Test business logic without caring about Firebase/Google APIs
4. **Separation of Concerns** - Domain defines "what", Data defines "how"
5. **Future-Proof** - New OAuth providers (Twitter, Microsoft) work out of the box

---

**This is exactly the kind of architectural thinking that separates good code from great code!** 🎯

Your instinct was 100% correct - having provider names in the Domain layer was indeed coupling. The generic credential approach is textbook clean architecture.

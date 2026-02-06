# Service Factory Pattern Guide

## Overview

The Service Factory pattern provides a clean, centralized way to switch between real and mock services in Debug and Release builds.

## Architecture

### ServiceConfiguration

Defines which services to use:

```swift
struct ServiceConfiguration {
    let useRealServices: Bool
    
    // Debug builds default to mock services
    // Release builds always use real services
    static let `default`: ServiceConfiguration
    
    // Force real services (for debug testing with real backends)
    static let production: ServiceConfiguration
    
    // Force mock services (for previews and UI testing)
    static let mock: ServiceConfiguration
}
```

### ServiceFactory

Creates services and repositories based on the configuration:

- `makeAuthService()` → `FirebaseAuthService` or `MockAuthService`
- `makeSubscriptionService()` → `RevenueCatSubscriptionService` or `MockSubscriptionService`
- `makeAIService()` → `GeminiAIService` or `MockAIService`
- `makeMindsetRepository()` → `SDMindsetRepository` or `MockMindsetRepository`
- `makeUserRepository()` → `SDUserRepository` or `MockUserRepository`

## Usage

### Default Behavior

In `MindsetApp.swift`:

```swift
// Uses .default configuration (mock in Debug, real in Release)
serviceFactory = ServiceFactory(config: .default)
```

**Debug builds**: All services are mocked (no real API calls, no Firebase, no RevenueCat)  
**Release builds**: All services are real (production behavior)

### Override for Testing

To test with **real services in Debug mode**:

```swift
// Force real services (useful for testing real Firebase/RevenueCat in debug)
serviceFactory = ServiceFactory(config: .production)
```

To test with **mock services in Release mode** (not recommended):

```swift
// Force mock services
serviceFactory = ServiceFactory(config: .mock)
```

### SwiftUI Previews

For SwiftUI previews, always use mock services:

```swift
#Preview {
    let factory = ServiceFactory(config: .mock)
    let authService = factory.makeAuthService()
    // ...
}
```

## Benefits

✅ **Clean separation**: One place to manage real vs mock services  
✅ **Type-safe**: All services conform to protocols  
✅ **Testable**: Easy to inject mocks for testing  
✅ **Compile-time safety**: No runtime service switching errors  
✅ **Conditional Firebase**: Firebase only initializes when using real services  
✅ **DRY principle**: No scattered `#if DEBUG` blocks throughout the codebase  
✅ **Easy to extend**: Add new services by implementing the protocol and adding a factory method

## Adding New Services

1. Define the protocol in `Domain/Protocols/`
2. Implement real service in `Data/Services/`
3. Implement mock service in `Domain/Mocks/`
4. Add factory method to `ServiceFactory`:

```swift
func makeMyNewService() -> MyNewService {
    if config.useRealServices {
        return RealMyNewService()
    } else {
        return MockMyNewService()
    }
}
```

5. Update `MindsetApp.swift` to use the factory method

## Performance Notes

- Mock services are **instant** (no network calls, no delays)
- Mock services have **pre-seeded data** for testing UI flows
- Firebase initialization is **skipped** when using mocks (faster app launch in debug)
- No API keys needed when using mocks

## Security Notes

- Mock services **never** make real API calls
- API keys are **not loaded** when using mocks
- User data stays **local** (no cloud sync) when using mocks

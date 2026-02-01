# Firebase Setup Guide

## Overview
Firebase provides authentication (Sign in with Apple) and cloud database (Firestore) for the Mindset app. This guide walks through setup from scratch.

## 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Name: `mindset-ios` (or your preference)
4. Enable Google Analytics (recommended for user insights)
5. Create project (takes ~1 minute)

## 2. Add iOS App to Firebase

1. In Firebase Console, click iOS+ icon
2. **iOS bundle ID:** `com.yourcompany.mindset-ios` (match your Xcode project)
3. **App nickname:** `Mindset iOS`
4. **App Store ID:** (leave blank for now)
5. Download `GoogleService-Info.plist`
6. **IMPORTANT:** Add to `.gitignore` (contains API keys)

```bash
# Add to .gitignore
echo "GoogleService-Info.plist" >> .gitignore
```

7. Drag `GoogleService-Info.plist` into Xcode project root (next to `Info.plist`)
   - ✓ Copy items if needed
   - ✓ Add to targets: mindset-ios

## 3. Install Firebase SDK via Swift Package Manager

1. In Xcode: File → Add Package Dependencies
2. Enter URL: `https://github.com/firebase/firebase-ios-sdk`
3. Version: Up to Next Major (11.0.0 or latest)
4. Add these products to `mindset-ios` target:
   - **FirebaseAuth** (authentication)
   - **FirebaseFirestore** (cloud database)
   - **FirebaseAnalytics** (optional, for metrics)

## 4. Enable Sign in with Apple

### In Firebase Console:
1. Go to Authentication → Sign-in method
2. Enable "Apple" provider
3. Note the "Service ID" (you'll need this for Xcode)

### In Apple Developer Portal:
1. Go to [developer.apple.com](https://developer.apple.com/)
2. Certificates, IDs & Profiles → Identifiers
3. Select your App ID (`com.yourcompany.mindset-ios`)
4. ✓ Enable "Sign in with Apple"
5. Click "Edit" → Configure:
   - Primary App ID: (auto-selected)
   - Save

### In Xcode:
1. Select `mindset-ios` target
2. Signing & Capabilities → + Capability
3. Add "Sign in with Apple"
4. This adds the entitlement automatically

## 5. Configure Firestore Database

1. In Firebase Console: Firestore Database → Create database
2. Choose **Start in test mode** (we'll add security rules later)
3. Location: `us-central1` (or nearest to your users)
4. Click "Enable"

### Add Security Rules (Important!)

In Firestore Console → Rules tab, replace with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Public read for app config (if needed)
    match /config/{document=**} {
      allow read: if true;
      allow write: if false;
    }
  }
}
```

Click "Publish"

## 6. Initialize Firebase in App

The initialization code will be added to `MindsetApp.swift`:

```swift
import SwiftUI
import FirebaseCore

@main
struct MindsetApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            MainCoordinatorView()
        }
    }
}
```

## 7. Data Structure in Firestore

Collections:
```
users/
  {userId}/
    profile/
      - userName: String
      - primaryGoal: String
      - createdAt: Timestamp
      - archetype: String
      
    entries/
      {entryId}/
        - date: Timestamp
        - responses: [PromptResponse]
        - aiAnalysis: String?
        - streak: Int
        
    subscription/
      - status: String ("active", "expired")
      - expiresAt: Timestamp
      - revenuecatId: String
```

## 8. RevenueCat Integration

Firebase UID should be used as RevenueCat App User ID:

```swift
// When user signs in with Firebase
let firebaseUID = Auth.auth().currentUser?.uid
Purchases.shared.logIn(firebaseUID) { (purchaserInfo, error) in
    // Now subscription status syncs with Firebase UID
}
```

## 9. Testing

### Test Sign in with Apple:
1. Run app on real device or simulator (iOS 13+)
2. Settings → Apple ID → Password & Security → Apps Using Apple ID
3. Remove "Mindset" if testing multiple times
4. Launch app, tap "Sign in with Apple"
5. First time: Choose email visibility (hide/show)
6. Subsequent times: Instant sign-in

### Test Firestore Sync:
1. Complete onboarding quiz
2. Sign in with Apple
3. Check Firebase Console → Firestore → users/{uid}/profile
4. Should see your profile data

## 10. Environment Variables (Optional)

If you want to support multiple environments (dev/prod):

1. Create `Config.config` (gitignored):
```
FIREBASE_PROJECT_ID = your-dev-project
FIREBASE_API_KEY = your-dev-api-key
```

2. Add to Xcode build settings:
   - Project → Info → Configurations
   - Create "Debug" and "Release" configs
   - Use different Firebase projects per environment

## 11. Common Issues

### "GoogleService-Info.plist not found"
- Make sure file is added to Xcode target (check File Inspector)
- Verify it's in the app bundle (Build Phases → Copy Bundle Resources)

### Sign in with Apple button not working
- Check Signing & Capabilities → "Sign in with Apple" is enabled
- Verify App ID has Sign in with Apple enabled in Apple Developer Portal
- Test on real device (Simulator uses sandbox)

### Firestore permission denied
- Check security rules allow `request.auth.uid == userId`
- Verify user is authenticated before writing to Firestore

### Firebase Analytics not working
- Add `FirebaseAnalytics` to SPM dependencies
- Check Info.plist has `FirebaseAppDelegateProxyEnabled = NO` if using custom initialization

## 12. Next Steps

After setup:
1. Implement `FirebaseAuthService` in Data module
2. Implement `FirebaseSyncService` in Data module
3. Create `FeatureAuth` module with `SignInView`
4. Update `MainCoordinator` to handle auth flow
5. Test end-to-end: Quiz → Sign In → Paywall → Dashboard

## Resources

- [Firebase iOS Quickstart](https://firebase.google.com/docs/ios/setup)
- [Sign in with Apple (Firebase)](https://firebase.google.com/docs/auth/ios/apple)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [RevenueCat + Firebase](https://www.revenuecat.com/docs/user-ids)

# Firebase Phone Auth Setup

## Error: "remote notifications need to be forwarded to FirebaseAuth's canHandleNotification"

This occurs when Firebase's app delegate swizzling is disabled or incompatible with SwiftUI. The app now includes `FirebasePhoneAuthAppDelegate` (via `UIApplicationDelegateAdaptor`) to forward remote notifications to Firebase Auth.

## Required Capabilities

For phone auth to work on a **physical device**, enable in Xcode → Signing & Capabilities:

1. **Push Notifications**
2. **Background Modes** → check **Remote notifications**

## APNS Key (Firebase Console)

1. Create an APNS authentication key in [Apple Developer Portal](https://developer.apple.com/account/resources/authkeys/list) (Keys → + → Apple Push Notifications)
2. Upload the `.p8` key to [Firebase Console](https://console.firebase.google.com) → Project Settings → Cloud Messaging → Apple app configuration → APNs Authentication Key

## Simulator Limitation

Push notifications **do not work on the iOS Simulator**. Phone auth on simulator may fall back to reCAPTCHA (in-app web view). For full testing, use a physical device.

# Fix Anonymous Sign-In Error

## 🔍 Problem
Getting "Sign In Error" when tapping "Continue without account" button.

## 🎯 Root Cause
**Most likely:** Anonymous Authentication is **NOT enabled** in Firebase Console.

Firebase requires you to manually enable each authentication method in the console before it can be used. Even though your code is correct, Firebase will reject anonymous sign-in attempts if the provider isn't enabled.

---

## ✅ Solution: Enable Anonymous Auth in Firebase Console

### Step 1: Open Firebase Console
1. Go to: https://console.firebase.google.com
2. Select your project: **mindset-ios**

### Step 2: Navigate to Authentication
1. In the left sidebar, click **"Build"**
2. Click **"Authentication"**
3. Click the **"Sign-in method"** tab at the top

### Step 3: Enable Anonymous Provider
1. Scroll down to **"Anonymous"** in the providers list
2. Click on **"Anonymous"**
3. Toggle **"Enable"** to ON
4. Click **"Save"**

### Step 4: Test Again
1. Rebuild and run your app
2. Tap "Continue without account"
3. Check the **debug overlay** (swipe gesture) for detailed logs:
   - ✅ Success: `"Anonymous sign-in successful: [userID]"`
   - ❌ Error: `"Anonymous sign-in failed: [detailed error]"`

---

## 🐛 Debugging: Check the Error Details

The app uses `DebugLogger` to capture the exact error. To see what's happening:

1. **Enable Debug Overlay** in your app (swipe gesture or shake)
2. Try "Continue without account" again
3. Check the debug log for the actual Firebase error message

**Common error messages:**

| Error | Cause | Solution |
|-------|-------|----------|
| `"This operation is not allowed"` | Anonymous auth disabled | Enable in Firebase Console ✅ |
| `"Network error"` | No internet / Firebase unreachable | Check network connection |
| `"App not authorized"` | Bundle ID mismatch | Verify `GoogleService-Info.plist` |

---

## 🔒 Security Note

Anonymous users:
- ✅ Get a unique Firebase UID
- ✅ Can use the app fully
- ⚠️ Data is lost if they uninstall (no way to recover anonymous accounts)
- 💡 Consider prompting to "upgrade" to Apple/Google sign-in later to save data

---

## 📚 Firebase Anonymous Auth Documentation

For reference: https://firebase.google.com/docs/auth/ios/anonymous-auth

---

## Related Files
- `SignInViewModel.swift` - Handles anonymous auth flow
- `FirebaseAuthService.swift` - Firebase implementation of anonymous sign-in
- `AuthService.swift` - Protocol defining auth methods

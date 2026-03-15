//
//  FirebasePhoneAuthAppDelegate.swift
//  mindset-ios
//
//  Forwards remote notifications to Firebase Auth so phone sign-in (reCAPTCHA)
//  works when app delegate swizzling is disabled.
//

import FirebaseAuth
import FirebaseCore
import UIKit

/// AppDelegate adapter that forwards remote notifications to Firebase Auth.
/// Required for Firebase phone authentication when swizzling is disabled.
final class FirebasePhoneAuthAppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Configure Firebase before any Auth API calls (e.g. setAPNSToken in didRegisterForRemoteNotifications).
        // AppDependencyContainer may configure again when useRealServices; configure() is idempotent.
        FirebaseApp.configure()
        application.registerForRemoteNotifications()
        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        guard FirebaseApp.app() != nil else { return }
        #if DEBUG
        Auth.auth().setAPNSToken(deviceToken, type: .sandbox)
        #else
        Auth.auth().setAPNSToken(deviceToken, type: .prod)
        #endif
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        if FirebaseApp.app() != nil, Auth.auth().canHandleNotification(userInfo) {
            completionHandler(.noData)
            return
        }
        completionHandler(.noData)
    }
}

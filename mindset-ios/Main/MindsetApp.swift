//
//  MindsetApp.swift
//  mindset-ios
//
//  Created by patrick ridd on 1/2/26.
//

#if DEBUG
import Development
#endif
import Domain
import FeatureNavigation
import Firebase
import SharedUI
import SharedUtils
import SwiftData
import SwiftUI

@main
struct MindsetApp: App {
    @UIApplicationDelegateAdaptor(FirebasePhoneAuthAppDelegate.self) private var appDelegate
    @State private var appRootID = UUID()

    // Use `@StateObject` because it has a built-in lazy initialization mechanism - only creating the object the first time the view is loaded.
    // This prevents the Firebase Race Conditions (crashes)
    @StateObject private var dependencyContainer: AppDependencyContainer = AppDependencyContainer()
    
    var body: some Scene {
        WindowGroup {
            MainCoordinatorView(
                coordinator: dependencyContainer.coordinator,
                factory: dependencyContainer.viewFactory
            )
            .modifier(DebugWrapper())
            .onReceive(NotificationCenter.default.publisher(for: .restartApp)) { _ in
                 restartApp()
            }
            .onOpenURL { url in
                _ = dependencyContainer.authService.handleAuthCallback(url: url)
            }
            .id(appRootID)
        }
        .modelContainer(dependencyContainer.container)
    }

    func restartApp() {
        // Wipe the data using the current (active) container
        Task {
            do {
                try await dependencyContainer.persistence.deleteAllLocalUserData()
                
                // Once data is gone, reset the UI identity on the Main Actor
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        appRootID = UUID()
                    }
                    DebugLogger.shared.log("🔄 Local Data Wiped & App Environment Reset")
                }
            } catch {
                DebugLogger.shared.log("❌ Failed to wipe data during restart: \(error)")
            }
        }
    }
}

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
    @StateObject private var dependencyContainer: AppDependencyContainer = AppDependencyContainer()
    @State private var appRootID = UUID()
    
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
        withAnimation(.easeInOut(duration: 0.5)) {
            DebugLogger.shared.log("🔄 Restarting app...")
            appRootID = UUID()
        }
    }
}

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
import SharedUI
import SwiftData
import SwiftUI

@main
struct MindsetApp: App {
    @UIApplicationDelegateAdaptor(FirebasePhoneAuthAppDelegate.self) private var appDelegate
    @State private var appRootID = UUID()
    @State private var dependencyContainer = AppDependencyContainer()

    var body: some Scene {
        WindowGroup {
            MainCoordinatorView(
                coordinator: dependencyContainer.coordinator,
                factory: dependencyContainer.viewFactory
            )
            .modifier(DebugWrapper())
            .onReceive(NotificationCenter.default.publisher(for: .restartApp)) { _ in
                dependencyContainer = AppDependencyContainer()
                
                withAnimation(.easeInOut(duration: 0.5)) {
                    appRootID = UUID()
                }
            }
            .onOpenURL { url in
                _ = dependencyContainer.authService.handleAuthCallback(url: url)
            }
            .id(appRootID)
        }
        .modelContainer(dependencyContainer.container)
    }
}

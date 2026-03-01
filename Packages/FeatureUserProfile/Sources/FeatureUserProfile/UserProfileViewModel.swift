//
//  UserProfileViewModel.swift
//  FeatureUserProfile
//
//  Created by Mindset Team on 2/1/26.
//

import Domain
import Foundation
import Observation
import SharedUtils

@Observable
@MainActor
public final class UserProfileViewModel {
    public var isSigningOut = false
    public var showSignOutConfirmation = false
    var showRestartAlert = false
    var errorMessage: String?

    private let authService: AuthService
    private let userRepository: UserRepository
    private let onSignOut: () -> Void
    private var onNavigateToSecurity: () -> Void
    private var onNavigateToDebugTools: () -> Void

    public var userID: String?
    public var displayName: String?

    // This property acts as the UI state
    var useMocks: Bool {
        get { DebugSettings.shared.useMocks }
        set {
            DebugSettings.shared.useMocks = newValue
            showRestartAlert = true
            DebugLogger.shared.add(environmentDescription)
        }
    }
    
    var environmentDescription: String {
        "Toggled to: \(DebugSettings.shared.useMocks ? " 🧪 Debug (mocks)" : " 🌐 Production")"
    }

    public init(
        authService: AuthService,
        userRepository: UserRepository,
        onNavigateToSecurity: @escaping () -> Void,
        onSignOut: @escaping () -> Void,
        onNavigateToDebugTools: @escaping () -> Void = {}
    ) {
        self.authService = authService
        self.userRepository = userRepository
        self.onSignOut = onSignOut
        self.onNavigateToSecurity = onNavigateToSecurity
        self.onNavigateToDebugTools = onNavigateToDebugTools
        Task {
            await loadUserInfo()
        }
    }

    private func loadUserInfo() async {
        // Get current user ID
        userID = await authService.getCurrentUserID()

        // Get user profile from repository
        if let profile = try? await userRepository.fetchUserProfile() {
            displayName = profile.userName
        }

        // Fallback to stored display name
        if displayName == nil || displayName?.isEmpty == true {
            displayName = UserDefaults.standard.string(forKey: "userName")
        }
    }

    // MARK: Navigation State
    
    public func confirmSignOut() {
        showSignOutConfirmation = true
    }

    public func cancelSignOut() {
        showSignOutConfirmation = false
    }
    
    func navigateToSecurity() {
        onNavigateToSecurity()
    }

    func navigateToDebugTools() {
        onNavigateToDebugTools()
    }

    public func signOut() async {
        isSigningOut = true
        showSignOutConfirmation = false

        do {
            try await authService.signOut()

            // Clear local user data
            UserDefaults.standard.removeObject(forKey: "userName")
            UserDefaults.standard.removeObject(forKey: "currentNonce")
            UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")

            isSigningOut = false
            onSignOut()

        } catch {
            isSigningOut = false
            errorMessage = "Failed to sign out: \(error.localizedDescription)"
        }
    }

    public func dismissError() {
        errorMessage = nil
    }

    func restartApp() {
        NotificationCenter.default.post(name: .restartApp, object: nil)
    }
}

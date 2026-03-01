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
    public var errorMessage: String?

    private let authService: AuthService
    private let userRepository: UserRepository
    private let onSignOut: () -> Void
    private var onNavigateToSecurity: () -> Void

    public var userID: String?
    public var displayName: String?

    // This property acts as the UI state
    var useMocks: Bool {
        get { DebugSettings.shared.useMocks }
        set {
            DebugSettings.shared.useMocks = newValue
            // Trigger haptic or log here since it's a debug action
            DebugLogger.shared.add("🧪 Debug: Mocks set to \(newValue)")
        }
    }

    public init(
        authService: AuthService,
        userRepository: UserRepository,
        onNavigateToSecurity: @escaping () -> Void,
        onSignOut: @escaping () -> Void
    ) {
        self.authService = authService
        self.userRepository = userRepository
        self.onSignOut = onSignOut
        self.onNavigateToSecurity = onNavigateToSecurity
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
        HapticManager.selection()
        onNavigateToSecurity()
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
}

//
//  SettingsViewModel.swift
//  FeatureUserProfile
//
//  Created by patrick ridd on 3/3/26.
//

import Domain
import Foundation
import Observation

@Observable
@MainActor
public final class SettingsViewModel {
    public var isSigningOut = false
    public var showSignOutConfirmation = false
    var errorMessage: String?

    private let authService: AuthService
    private let onSignOut: () -> Void

    public init(
        authService: AuthService,
        onSignOut: @escaping () -> Void
    ) {
        self.authService = authService
        self.onSignOut = onSignOut
    }

    public func confirmSignOut() {
        showSignOutConfirmation = true
    }

    public func cancelSignOut() {
        showSignOutConfirmation = false
    }

    public func signOut() async {
        guard !isSigningOut else { return }

        isSigningOut = true
        showSignOutConfirmation = false

        do {
            try await authService.signOut()

            UserDefaults.standard.removeObject(forKey: "userName")
            UserDefaults.standard.removeObject(forKey: "currentNonce")

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

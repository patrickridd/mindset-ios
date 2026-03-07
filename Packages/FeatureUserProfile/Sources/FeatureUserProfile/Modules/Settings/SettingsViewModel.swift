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
    public var isDeletingAccount = false
    var activeSheet: SettingsSheet?

    var errorTitle = FeatureUserProfileStrings.SignOut.errorTitle
    var errorMessage: String?

    private let authService: AuthService
    private let persistence: PersistenceService
    private let onSignOut: () -> Void
    private let onDeleteAccount: () -> Void
    private let onNavigateToPrivacyPolicy: () -> Void
    private(set) var onNavigateToSecureAccount: (() -> Void)?

    public init(
        authService: AuthService,
        persistence: PersistenceService,
        onSignOut: @escaping () -> Void,
        onDeleteAccount: @escaping () -> Void,
        onNavigateToPrivacyPolicy: @escaping () -> Void,
        onNavigateToSecureAccount: (() -> Void)? = nil
    ) {
        self.authService = authService
        self.persistence = persistence
        self.onSignOut = onSignOut
        self.onDeleteAccount = onDeleteAccount
        self.onNavigateToPrivacyPolicy = onNavigateToPrivacyPolicy
        self.onNavigateToSecureAccount = onNavigateToSecureAccount
    }

    var isAccountSecurelyLinked: Bool {
        authService.isAnonymousAccountLinked()
    }

    var shouldDisplaySignOutButton: Bool  {
        isAccountSecurelyLinked
    }

    var isBusy: Bool {
        isSigningOut || isDeletingAccount
    }

    // MARK: Localized Strings
    
    var busyOverlayText: String {
        if isDeletingAccount {
            FeatureUserProfileStrings.DeleteAccount.deleting
        } else {
            FeatureUserProfileStrings.SignOut.signingOut
        }
    }
    
    var deleteAccountButtonTitle: String {
        authService.isAnonymousAccountLinked() ?
        FeatureUserProfileStrings.DeleteAccount.buttonTitle :
        FeatureUserProfileStrings.DeleteAccount.buttonAnonymousTitle
    }

    var deleteAccountConfirmationTitle: String {
        authService.isAnonymousAccountLinked() ?
        FeatureUserProfileStrings.DeleteAccount.confirmationTitle :
        FeatureUserProfileStrings.DeleteAccount.confirmationAnonymousTitle
    }

    var deleteAccountConfirmationSubtitle: String {
        authService.isAnonymousAccountLinked() ?
        FeatureUserProfileStrings.DeleteAccount.confirmationSubtitle :
        FeatureUserProfileStrings.DeleteAccount.confirmationAnonymousSubtitle
    }
    
    var linkAccountRow: (icon: String, title: String, subtTitle: String) {
        if isAccountSecurelyLinked  {
            (icon: "checkmark.shield.fill",
             title: FeatureUserProfileStrings.Account.accountSecuredRowTitle,
             subtTitle: FeatureUserProfileStrings.Account.accountSecuredRowSubtitle)
        }  else {
            (icon: "shield.slash",
             title: FeatureUserProfileStrings.Account.accountNOTSecuredRowTitle,
             subtTitle: FeatureUserProfileStrings.Account.accountNOTSecuredRowSubtitle)
        }
    }

    // MARK: - Actions
    
    public func presentConfirmSignOut() {
        guard !isBusy else { return }
        activeSheet = .signOut
    }

    public func cancelSignOut() {
        dismissConfirmationSheet()
    }

    public func dismissConfirmationSheet() {
        activeSheet = nil
    }

    public func signOut() async {
        guard !isBusy else { return }

        isSigningOut = true
        dismissConfirmationSheet()

        do {
            try await authService.signOut()

            UserDefaults.standard.removeObject(forKey: "userName")
            UserDefaults.standard.removeObject(forKey: "currentNonce")

            isSigningOut = false
            onSignOut()
        } catch {
            isSigningOut = false
            errorTitle = FeatureUserProfileStrings.SignOut.errorTitle
            errorMessage = "Failed to sign out: \(error.localizedDescription)"
        }
    }

    public func presentDeleteAccountConfirmation() {
        guard !isBusy else { return }
        activeSheet = .deleteAccount
    }

    public func cancelDeleteAccount() {
        dismissConfirmationSheet()
    }

    public func deleteAccount() async {
        guard !isBusy else { return }

        isDeletingAccount = true
        dismissConfirmationSheet()

        do {
            try await authService.deleteCurrentUser()
            try await persistence.deleteAllUserData()

            UserDefaults.standard.removeObject(forKey: "userName")
            UserDefaults.standard.removeObject(forKey: "currentNonce")

            isDeletingAccount = false
            onDeleteAccount()
        } catch {
            isDeletingAccount = false
            errorTitle = FeatureUserProfileStrings.DeleteAccount.errorTitle
            errorMessage = "Failed to delete account: \(error.localizedDescription)"
        }
    }

    public func dismissError() {
        errorMessage = nil
    }

    public func navigateToPrivacyPolicy() {
        guard !isBusy else { return }
        onNavigateToPrivacyPolicy()
    }
}

enum SettingsSheet: Identifiable {
    case signOut
    case deleteAccount

    var id: Int {
        switch self {
        case .signOut: 0
        case .deleteAccount: 1
        }
    }
}

//
//  UserProfileViewModel.swift
//  FeatureUserProfile
//
//  Created by Mindset Team on 2/1/26.
//

import Domain
import Foundation
import Observation

@Observable
public final class UserProfileViewModel {
    public let isDebugToolsAvailable: Bool

    private let authStateQuery: AuthStateQuery
    private let userRepository: UserRepository
    private var onNavigateToSecurity: () -> Void
    private var onNavigateToDebugTools: () -> Void

    public var userID: String?
    public var displayName: String?

    public init(
        authStateQuery: AuthStateQuery,
        userRepository: UserRepository,
        isDebugToolsAvailable: Bool = false,
        onNavigateToSecurity: @escaping () -> Void,
        onNavigateToDebugTools: @escaping () -> Void = {}
    ) {
        self.authStateQuery = authStateQuery
        self.userRepository = userRepository
        self.isDebugToolsAvailable = isDebugToolsAvailable
        self.onNavigateToSecurity = onNavigateToSecurity
        self.onNavigateToDebugTools = onNavigateToDebugTools
        Task {
            await loadUserInfo()
        }
    }

    private func loadUserInfo() async {
        // Get current user ID
        userID = await authStateQuery.getCurrentUserID()

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
    
    func navigateToSecurity() {
        onNavigateToSecurity()
    }

    func navigateToDebugTools() {
        guard isDebugToolsAvailable else { return }
        onNavigateToDebugTools()
    }
}

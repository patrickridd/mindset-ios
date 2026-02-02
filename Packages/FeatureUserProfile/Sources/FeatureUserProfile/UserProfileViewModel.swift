//
//  UserProfileViewModel.swift
//  FeatureUserProfile
//
//  Created by Mindset Team on 2/1/26.
//

import Foundation
import Observation
import Domain

@Observable
@MainActor
public final class UserProfileViewModel {
    public var isSigningOut = false
    public var showSignOutConfirmation = false
    public var errorMessage: String?
    
    private let authService: AuthService
    private let userRepository: UserRepository
    private let onSignOut: () -> Void
    
    public var userID: String?
    public var displayName: String?
    
    public init(
        authService: AuthService,
        userRepository: UserRepository,
        onSignOut: @escaping () -> Void
    ) {
        self.authService = authService
        self.userRepository = userRepository
        self.onSignOut = onSignOut
        
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
    
    public func confirmSignOut() {
        showSignOutConfirmation = true
    }
    
    public func cancelSignOut() {
        showSignOutConfirmation = false
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

//
//  UserSyncService.swift
//  Domain
//
//  Created by patrick ridd on 3/20/26.
//

@MainActor
public final class UserSyncService: Sendable {
    private let userRepository: UserRepository
    private let authService: AuthService
    private let logger: AppLogger

    public init(userRepository: UserRepository, authService: AuthService, logger: AppLogger) {
        self.userRepository = userRepository
        self.authService = authService
        self.logger = logger
    }

    public func syncUserOnLaunch() async {
        // 1. Ensure we have a UID (This is our 'Gate')
        guard let uid = await authService.getCurrentUserID() else {
            logger.log("🚪 No UID found, skipping launch sync.")
            return
        }

        do {
            // 2. Simply 'fetch'.
            // This returns local data INSTANTLY to the UI.
            // But because it's AppUserRepository, it triggers the 'resolveSync' Task
            // in the background to check Firestore.
            let profile = try await userRepository.fetchUserProfile()
            
            // 3. Fallback: If absolutely no profile exists anywhere (Local OR Remote)
            // resolveSync won't find anything, so we provision a fresh one.
            if profile == nil {
                logger.log("✨ No profile found. Provisioning fresh anchor.")
                let newProfile = UserProfile.anonymousUser(id: uid)
                try await userRepository.saveUserProfile(newProfile)
            }
            
            logger.log("✅ Launch Sync Triggered.")
        } catch {
            logger.log("⚠️ Launch Sync Poke failed: \(error)")
        }
    }
}

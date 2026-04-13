//
//  AppSyncService.swift
//  Domain
//
//  Created by patrick ridd on 3/20/26.
//

import Foundation

@MainActor
public final class AppSyncService: Sendable {
    private let userLocal: UserRepository
    private let userRemote: UserRepository
    private let entryLocal: EntryRepository
    private let entryRemote: EntryRepository
    private let userStatsLocal: UserStatsRepository & UserStatsSyncable
    private let userStatsRemote: UserStatsRepository & UserStatsSyncable
    private let authService: AuthService
    private let notificationCenter: NotificationCenter
    private let logger: AppLogger

    public init(
        userLocal: UserRepository,
        userRemote: UserRepository,
        entryLocal: EntryRepository,
        entryRemote: EntryRepository,
        userStatsLocal: UserStatsRepository & UserStatsSyncable,
        userStatsRemote: UserStatsRepository & UserStatsSyncable,
        authService: AuthService,
        notificationCenter: NotificationCenter = .default,
        logger: AppLogger
    ) {
        self.userLocal = userLocal
        self.userRemote = userRemote
        self.entryLocal = entryLocal
        self.entryRemote = entryRemote
        self.userStatsLocal = userStatsLocal
        self.userStatsRemote = userStatsRemote
        self.authService = authService
        self.notificationCenter = notificationCenter
        self.logger = logger
    }

    public func syncAllData() async {
        guard let uid = await authService.getCurrentUserID() else {
            logger.log("🚪 No UID found, skipping launch sync.")
            return
        }
        
        // Run both in parallel for speed
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.syncUser(uid: uid) }
            group.addTask { await self.syncEntries(uid: uid) }
            group.addTask { await self.syncUserStats(uid: uid) }
        }
    }
}

// MARK: - User Sync

extension AppSyncService {

    public func syncUser(uid: String) async {
        do {
            // 1. Fetch current states from both worlds
            let localUser = try await userLocal.fetchUser()
            let remoteUser = try await userRemote.fetchUser()

            // 2. Identify the situation using your SyncState enum
            let state = SyncState(localUser: localUser, remoteUser: remoteUser, uid: uid)

            // 3. Resolve the state
            switch state {
            case .newUserCreation(let uid):
                logger.log("✨ Provisioning brand new user anchor.")
                let newProfile = User.anonymousUser(id: uid)
                try await userLocal.saveUser(newProfile)
                try await userRemote.saveUser(newProfile)

            case .remoteOnly(let remote):
                logger.log("☁️ Bootstrapping local store from Cloud.")
                try await userLocal.saveUser(remote)
                notificationCenter.post(name: .databaseDidChange, object: nil)

            case .localOnly(let local):
                logger.log("🛠 Uploading local profile to Cloud anchor.")
                try await userRemote.saveUser(local)

            case .resolve(let local, let remote):
                try await handleComparison(local: local, remote: remote)
            }

            logger.log("✅ User Sync Sequence Completed.")
        } catch {
            logger.log("⚠️ User Sync failed: \(error.localizedDescription)")
        }
    }
    
    private func handleComparison(local: User, remote: User) async throws {
        // Use a 1-second leeway to ignore nanosecond jitter between DBs
        let timeDiff = abs(remote.lastUpdatedAt.timeIntervalSince(local.lastUpdatedAt))
        
        if timeDiff < 1.0 {
            logger.log("✅ Sync: Profiles are already in parity.")
            return
        }

        if remote.lastUpdatedAt > local.lastUpdatedAt {
            logger.log("🔄 Sync: Cloud is newer. Updating local.")
            try await userLocal.saveUser(remote)
            notificationCenter.post(name: .databaseDidChange, object: nil)
        } else {
            logger.log("🔄 Sync: Local is newer. Updating cloud.")
            try await userRemote.saveUser(local)
        }
    }

    private enum SyncState {
        case newUserCreation(uid: String)
        case remoteOnly(remote: User)
        case localOnly(local: User)
        case resolve(local: User, remote: User)

        init(localUser: User?, remoteUser: User?, uid: String) {
            switch (localUser, remoteUser) {
            // 1. Total Void: New User / First Sign In
            case (nil, nil):
                self = .newUserCreation(uid: uid)
            // 2. New Device / Data Recovery: Remote exists, Local doesn't
            case (nil, .some(let remoteUser)):
                self = .remoteOnly(remote: remoteUser)
            // 3. First-time Upload: Local exists, Remote doesn't (or document was deleted)
            case (.some(let localUser), nil):
                self = .localOnly(local: localUser)
            // 4. Comparison: Both exist, may the newest timestamp win
            case (.some(let localUser), .some(let remoteUser)):
                self = .resolve(local: localUser, remote: remoteUser)
            }
        }
    }
}

// MARK: - Entry Sync

extension AppSyncService {
    private func syncEntries(uid: String) async {
        do {
            let localEntries = try await entryLocal.fetchAllEntries()
            let remoteEntries = try await entryRemote.fetchAllEntries()
            
            // Logic: Merge by ID, newest timestamp wins
            // (I can help you write the specific 'Merge' logic next)
            await resolveEntrySync(local: localEntries, remote: remoteEntries)
            
            logger.log("✅ Entries Synced.")
        } catch {
            logger.log("⚠️ Entry Sync failed: \(error)")
        }
    }

    private func resolveEntrySync(local: [Entry], remote: [Entry]) async {
        // 1. Create a map of Remote entries for O(1) lookup
        let remoteMap = Dictionary(uniqueKeysWithValues: remote.map { ($0.id, $0) })
        let localMap = Dictionary(uniqueKeysWithValues: local.map { ($0.id, $0) })
        
        var entriesToUpload: [Entry] = []
        var entriesToDownload: [Entry] = []

        // 2. Identify what needs to go UP or be RESOLVED
        for localEntry in local {
            if let remoteEntry = remoteMap[localEntry.id] {
                // CONFLICT: Both exist. Compare timestamps.
                if localEntry.lastUpdatedAt > remoteEntry.lastUpdatedAt {
                    entriesToUpload.append(localEntry)
                } else if remoteEntry.lastUpdatedAt > localEntry.lastUpdatedAt {
                    entriesToDownload.append(remoteEntry)
                }
            } else {
                // NEW LOCAL: Doesn't exist on remote yet.
                entriesToUpload.append(localEntry)
            }
        }

        // 3. Identify what needs to come DOWN (Remote exists, but Local doesn't)
        for remoteEntry in remote {
            if localMap[remoteEntry.id] == nil {
                entriesToDownload.append(remoteEntry)
            }
        }

        // 4. Execute the Batch Updates
        await performSyncActions(upload: entriesToUpload, download: entriesToDownload)
    }

    private func performSyncActions(upload: [Entry], download: [Entry]) async {
        guard !upload.isEmpty || !download.isEmpty else {
            logger.log("✅ Entry Sync: All entries already in parity.")
            return
        }

        // Upload New/Updated to Remote
        for entry in upload {
            try? await entryRemote.save(entry: entry)
        }

        // Download New/Updated to Local
        for entry in download {
            try? await entryLocal.save(entry: entry)
        }

        if !download.isEmpty {
            notificationCenter.post(name: .databaseDidChange, object: nil)
            logger.log("📥 Entry Sync: Downloaded \(download.count) entries.")
        }
        
        if !upload.isEmpty {
            logger.log("📤 Entry Sync: Uploaded \(upload.count) entries.")
        }
    }
}

// MARK: - Stats Sync
extension AppSyncService {
    public func syncUserStats(uid: String) async {
        do {
            let localStats = try await userStatsLocal.fetchStats(userId: uid)
            let remoteStats = try await userStatsRemote.fetchStats(userId: uid)
            
            switch (localStats, remoteStats) {
            case (nil, nil):
                logger.log("📊 UserStats: No stats found anywhere. Waiting for first ritual.")
                
            case (nil, .some(let remote)):
                logger.log("📊 UserStats: Downloading stats from cloud.")
                try await userStatsLocal.updateStats(userId: uid, xpDelta: remote.totalXP, newStreak: remote.currentStreak)
                
            case (.some(let local), nil):
                logger.log("📊 UserStats: Uploading local stats to cloud.")
                try await userStatsRemote.updateStats(userId: uid, xpDelta: local.totalXP, newStreak: local.currentStreak)

            case (.some(let local), .some(let remote)):
                try await resolveUserStatsConflict(uid: uid, local: local, remote: remote)
            }
        } catch {
            logger.log("⚠️ UserStats Sync failed: \(error.localizedDescription)")
        }
    }
    
    private func resolveUserStatsConflict(uid: String, local: UserStats, remote: UserStats) async throws {
        let localDate = local.lastUpdated ?? .distantPast
        let remoteDate = remote.lastUpdated ?? .distantPast
        
        let timeDiff = abs(remoteDate.timeIntervalSince(localDate))
        if timeDiff < 1.0 { return }
        
        if remoteDate > localDate {
            logger.log("🔄 UserStats Sync: Cloud is newer. Overwriting local.")
            
            // We use overwriteStats to avoid 'double-adding' XP via deltas
            try await userStatsLocal.overwriteStats(
                userId: uid,
                totalXP: remote.totalXP,
                newStreak: remote.currentStreak,
                lastUpdated: remoteDate // Preserve the original timestamp!
            )
        } else {
            logger.log("🔄 UserStats Sync: Local is newer. Overwriting cloud.")
            
            try await userStatsRemote.overwriteStats(
                userId: uid,
                totalXP: local.totalXP,
                newStreak: local.currentStreak,
                lastUpdated: localDate
            )
        }
    }
}

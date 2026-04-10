//
//  UserStatsRepositoryDebugWrapper.swift
//  Development
//
//  Created by patrick ridd on 4/10/26.
//

import Domain
import Foundation

/// Decorator that intercepts `UserStatsRepository` calls and decorates with debug overrides
/// from `DebugSettings` before delegating to the wrapped service.
/// Injected at the `ServiceFactory` level in `#if DEBUG` builds only.
public final class UserStatsRepositoryDebugWrapper: UserStatsRepository, @unchecked Sendable {
    
    private let wrapped: any UserStatsRepository & UserStatsSyncable

    public init(wrapping service: any UserStatsRepository & UserStatsSyncable) {
        self.wrapped = service
    }

    public func fetchStats(userId: String) async throws -> Domain.UserStats? {
        try await wrapped.fetchStats(userId: userId)
    }

    public func incrementTotalXP(userId: String, by amount: Int) async throws {
        try await wrapped.incrementTotalXP(userId: userId, by: amount)
    }

    public func updateStats(userId: String, xpDelta: Int, newStreak: Int) async throws {
        try await wrapped.updateStats(userId: userId, xpDelta: xpDelta, newStreak: newStreak)
    }
}

extension UserStatsRepositoryDebugWrapper: UserStatsSyncable {
    public func overwriteStats(userId: String, totalXP: Int, newStreak: Int, lastUpdated: Date) async throws {
        try await wrapped.overwriteStats(userId: userId, totalXP: totalXP, newStreak: newStreak, lastUpdated: lastUpdated)
    }
}

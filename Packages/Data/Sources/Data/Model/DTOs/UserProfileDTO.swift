//
//  UserProfileDTO.swift
//  Data
//
//  Created by patrick ridd on 3/18/26.
//

import Domain
import Foundation

/// A lightweight, Codable representation of a ``UserProfile`` for remote storage.
///
/// This DTO is used to serialize user data for Firestore. It maintains strict parity
/// with the Domain model to ensure no data loss during synchronization.
public struct UserProfileDTO: Codable {
    public let id: String
    public let createdAt: Date
    public let userName: String
    public let isAccountSecured: Bool
    public let isOnboardingComplete: Bool
    public let onboardingData: OnboardingDataDTO
    public let stats: UserStatsDTO

    /// Maps a Domain ``UserProfile`` to a DTO for uploading.
    public init(from domain: UserProfile) {
        self.id = domain.id
        self.createdAt = domain.createdAt
        self.userName = domain.userName
        self.isAccountSecured = domain.isAccountSecured
        self.isOnboardingComplete = domain.isOnboardingComplete
        self.onboardingData = OnboardingDataDTO(from: domain.onboardingData)
        self.stats = UserStatsDTO(from: domain.stats)
    }

    /// Converts the DTO back into a Domain ``UserProfile``.
    public func toDomain() -> UserProfile {
        UserProfile(
            id: id,
            createdAt: createdAt,
            userName: userName,
            isAccountSecured: isAccountSecured,
            isOnboardingComplete: isOnboardingComplete,
            onboardingData: onboardingData.toDomain(),
            stats: stats.toDomain()
        )
    }
}

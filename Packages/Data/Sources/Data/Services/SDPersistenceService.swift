//
//  SwiftDataPersistenceService.swift
//  Data
//
//  Created by patrick ridd on 1/9/26.
//

import Domain
import Foundation
import SwiftData

@MainActor
public final class SDPersistenceService: PersistenceService {

    private let modelContext: ModelContext

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    public func saveUserProfile(_ profile: UserProfile) async throws {
        // 1. Check if one exists (to maintain our 'Unique' constraint)
        let descriptor = FetchDescriptor<SDUserProfile>()
        let existing = try modelContext.fetch(descriptor).first

        if let existing {
            // Update existing
            existing.bestSelfName = profile.userName
            existing.primaryGoal = profile.primaryGoal
            existing.overwhelmedFrequency = profile.overwhelmedFrequency.rawValue
            existing.isOnboardingComplete = profile.isOnboardingComplete
            existing.isAccountSecured = profile.isAccountSecured
            existing.headspaceRaw = profile.headspace?.rawValue
            existing.mentalMuscleRaw = profile.mentalMuscle?.rawValue
            existing.responseToSetbackRaw = profile.responseToSetback?.rawValue
            existing.habitGoalRaw = profile.habitGoal?.rawValue
            existing.aiCoachToneRaw = profile.aiCoachTone?.rawValue
        } else {
            // Insert new
            let sdModel = SDUserProfile.fromDomain(profile)
            modelContext.insert(sdModel)
        }
        try modelContext.save()
    }

    public func fetchUserProfile() async throws -> UserProfile? {
        let descriptor = FetchDescriptor<SDUserProfile>()
        // 2. Map the @Model back to a Domain Struct
        return try modelContext.fetch(descriptor).first?.toDomain()
    }

    public func saveMindsetEntry(_ entry: Domain.MindsetEntry) async throws {
        // Map and save the daily ritual
        let sdEntry = SDMindsetEntry.fromDomain(entry)
        modelContext.insert(sdEntry)
        try modelContext.save()
    }

    public func fetchAllMindsetEntries() async throws -> [Domain.MindsetEntry] {
        let descriptor = FetchDescriptor<SDMindsetEntry>(sortBy: [
            SortDescriptor(\SDMindsetEntry.date, order: .reverse)
        ])
        let dbEntries = try modelContext.fetch(descriptor)
        return dbEntries.map { $0.toDomain() }
    }

    public func deleteAllUserData() async throws {
        let profileDescriptor = FetchDescriptor<SDUserProfile>()
        let profiles = try modelContext.fetch(profileDescriptor)
        for profile in profiles {
            modelContext.delete(profile)
        }

        let entryDescriptor = FetchDescriptor<SDMindsetEntry>()
        let entries = try modelContext.fetch(entryDescriptor)
        for entry in entries {
            modelContext.delete(entry)
        }

        try modelContext.save()
    }
}

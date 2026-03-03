//
//  AppDefaultsStore.swift
//  Data
//

import Domain
import Foundation

/// Production implementation of `AppDefaults` backed by `UserDefaults`.
public final class AppDefaultsStore: AppDefaults {
    @UserDefault(key: "onboardingComplete", defaultValue: false)
    public var onboardingComplete: Bool

    public init() {
        migrateLegacyOnboardingFlagIfNeeded()
    }

    private func migrateLegacyOnboardingFlagIfNeeded() {
        let newKey = "onboardingComplete"
        let legacyKey = "hasCompletedOnboarding"

        guard UserDefaults.standard.object(forKey: newKey) == nil else { return }
        guard UserDefaults.standard.bool(forKey: legacyKey) else { return }

        onboardingComplete = true
        UserDefaults.standard.removeObject(forKey: legacyKey)
    }
}

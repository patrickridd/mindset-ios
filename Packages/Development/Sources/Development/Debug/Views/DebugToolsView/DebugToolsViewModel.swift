//
//  DebugToolsViewModel.swift
//  Development
//

import Domain
import Foundation
import Observation
import SharedUtils

@Observable
@MainActor
public final class DebugToolsViewModel {
    public var showRestartAlert = false

    private let appDefaults: any AppDefaults
    private(set) var environmentDescription: String = "Restarting to apply changes..."
    private var isInitializing = true

    public var useMocks: Bool = false {
        didSet {
            guard !isInitializing else { return }
            let oldValue = DebugSettings.shared.useMocks
            guard oldValue != useMocks else { return }

            DebugSettings.shared.useMocks = useMocks
            environmentDescription = "Toggled to: \(useMocks ? "🧪 Debug (mocks)" : "🌐 Production")"
            DebugLogger.shared.add(environmentDescription)
            showRestartAlert = true
        }
    }

    public var isProOverrideEnabled: Bool = false {
        didSet {
            DebugSettings.shared.isProOverrideEnabled = isProOverrideEnabled
            DebugLogger.shared.add("isPro override \(isProOverrideEnabled ? "enabled" : "disabled")")
        }
    }

    public var isProOverrideValue: Bool = false {
        didSet {
            DebugSettings.shared.isProOverrideValue = isProOverrideValue
            DebugLogger.shared.add("isPro override value set to: \(isProOverrideValue)")
        }
    }

    public var onboardingOverrideEnabled: Bool = false {
        didSet {
            guard !isInitializing else { return }
            DebugSettings.shared.onboardingOverrideEnabled = onboardingOverrideEnabled
            DebugLogger.shared.add(
                "Onboarding override \(onboardingOverrideEnabled ? "enabled" : "disabled")"
            )
        }
    }

    public var onboardingOverrideValue: Bool = true {
        didSet {
            guard !isInitializing else { return }
            DebugSettings.shared.onboardingOverrideValue = onboardingOverrideValue
            DebugLogger.shared.add("Onboarding override value set to: \(onboardingOverrideValue)")
        }
    }
    
    public init(appDefaults: any AppDefaults) {
        self.appDefaults = appDefaults
        useMocks = DebugSettings.shared.useMocks
        isProOverrideEnabled = DebugSettings.shared.isProOverrideEnabled
        isProOverrideValue = DebugSettings.shared.isProOverrideValue
        onboardingOverrideEnabled = DebugSettings.shared.onboardingOverrideEnabled
        onboardingOverrideValue = DebugSettings.shared.onboardingOverrideValue
        // @Observable synthesizes setters for stored properties, causing didSet to fire during
        // init assignments. Reset any spurious side effects from that here.
        showRestartAlert = false
        isInitializing = false
    }

    public func restartApp() {
        NotificationCenter.default.post(name: .restartApp, object: nil)
    }
}

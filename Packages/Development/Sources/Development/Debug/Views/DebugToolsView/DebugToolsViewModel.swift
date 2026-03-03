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

    public var useMocks: Bool {
        get { DebugSettings.shared.useMocks }
        set {
            DebugSettings.shared.useMocks = newValue
            showRestartAlert = true
            DebugLogger.shared.add(environmentDescription)
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

    public var environmentDescription: String {
        "Toggled to: \(DebugSettings.shared.useMocks ? "🧪 Debug (mocks)" : "🌐 Production")"
    }

    public init() {
        isProOverrideEnabled = DebugSettings.shared.isProOverrideEnabled
        isProOverrideValue = DebugSettings.shared.isProOverrideValue
    }

    public func restartApp() {
        NotificationCenter.default.post(name: .restartApp, object: nil)
    }
}

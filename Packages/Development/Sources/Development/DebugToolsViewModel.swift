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

    public var environmentDescription: String {
        "Toggled to: \(DebugSettings.shared.useMocks ? "🧪 Debug (mocks)" : "🌐 Production")"
    }

    public init() {}

    public func restartApp() {
        NotificationCenter.default.post(name: .restartApp, object: nil)
    }
}

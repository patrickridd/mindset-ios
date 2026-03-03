//
//  DevelopmentStrings.swift
//  Development
//

import Foundation

/// Type-safe access to Development-package localized strings.
///
/// **Usage:**
/// ```swift
/// Text(DevelopmentStrings.DebugTools.sectionHeader)
/// Toggle(DevelopmentStrings.DebugTools.useMockServices, isOn: $viewModel.useMocks)
/// ```
public enum DevelopmentStrings {

    // MARK: - Debug Tools Screen

    public enum DebugTools {
        public static let sectionHeader = String(
            localized: "development.debugTools.sectionHeader", bundle: .module,
            comment: "Section header label above the debug toggles card on the Debug Tools screen")
        public static let useMockServices = String(
            localized: "development.debugTools.useMockServices", bundle: .module,
            comment: "Toggle label for switching between mock and real services")
        public static let restartingApp = String(
            localized: "development.debugTools.restartingApp", bundle: .module,
            comment: "Alert title shown when the app is about to restart after toggling services")
        public static let sectionHeaderSubscription = String(
            localized: "development.debugTools.sectionHeaderSubscription", bundle: .module,
            comment: "Section header above the isPro override card on the Debug Tools screen")
        public static let isProOverrideToggle = String(
            localized: "development.debugTools.isProOverrideToggle", bundle: .module,
            comment: "Toggle label that enables or disables the isPro debug override")
        public static let isProOverrideValue = String(
            localized: "development.debugTools.isProOverrideValue", bundle: .module,
            comment: "Toggle label that sets the overridden isPro value (Pro / Free)")
    }
}

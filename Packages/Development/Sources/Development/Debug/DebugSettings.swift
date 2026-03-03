//
//  DebugSettings.swift
//  Domain
//
//  Created by patrick ridd on 3/1/26.
//

import Data
import Foundation

@MainActor
public final class DebugSettings {
    public static let shared = DebugSettings()

    // Pure Foundation-based storage
    @UserDefault(key: "com.mindset.debug.useMocks", defaultValue: false)
    public var useMocks: Bool

    @UserDefault(key: "com.mindset.debug.isProOverrideEnabled", defaultValue: false)
    public var isProOverrideEnabled: Bool

    @UserDefault(key: "com.mindset.debug.isProOverrideValue", defaultValue: false)
    public var isProOverrideValue: Bool

    @UserDefault(key: "com.mindset.debug.onboardingOverrideEnabled", defaultValue: false)
    public var onboardingOverrideEnabled: Bool

    @UserDefault(key: "com.mindset.debug.onboardingOverrideValue", defaultValue: true)
    public var onboardingOverrideValue: Bool

    private init() {}
}

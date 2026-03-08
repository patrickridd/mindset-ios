//
//  DebugSettings.swift
//  Domain
//
//  Created by patrick ridd on 3/1/26.
//

import Foundation
import SharedUtils

@MainActor
public final class DebugSettings {
    public static let shared = DebugSettings()

    @UserDefaultWrapper(key: "com.mindset.debug.useMocks", defaultValue: false)
    public var useMocks: Bool

    @UserDefaultWrapper(key: "com.mindset.debug.isProOverrideEnabled", defaultValue: false)
    public var isProOverrideEnabled: Bool

    @UserDefaultWrapper(key: "com.mindset.debug.isProOverrideValue", defaultValue: false)
    public var isProOverrideValue: Bool

    @UserDefaultWrapper(key: "com.mindset.debug.onboardingOverrideEnabled", defaultValue: false)
    public var onboardingOverrideEnabled: Bool

    @UserDefaultWrapper(key: "com.mindset.debug.onboardingOverrideValue", defaultValue: true)
    public var onboardingOverrideValue: Bool

    private init() {}
}

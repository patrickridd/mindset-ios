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

    private init() {}
}

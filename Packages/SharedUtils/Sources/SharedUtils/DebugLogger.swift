//
//  DebugLogger.swift
//  SharedUtils
//
//  Created by patrick ridd on 1/25/26.
//


import Foundation
import Observation

@Observable
public final class DebugLogger: @unchecked Sendable {
    public static let shared = DebugLogger()
    public var logs: [String] = []

    private init() {} // Singleton
    
    public func add(_ message: String) {
        let timestamp = Date().formatted(.dateTime.hour().minute().second())
        // Keep it thread-safe and on the main actor for UI updates
        Task { @MainActor in
            logs.insert("[\(timestamp)] \(message)", at: 0)
            if logs.count > 30 { logs.removeLast() }
        }
    }
}

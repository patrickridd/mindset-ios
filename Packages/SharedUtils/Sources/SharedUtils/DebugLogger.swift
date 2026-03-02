//
//  DebugLogger.swift
//  SharedUtils
//
//  Created by patrick ridd on 1/25/26.
//

import Domain
import Foundation
import Observation

@Observable
public final class DebugLogger: AppLogger, @unchecked Sendable {
    public static let shared = DebugLogger()
    public var logs: [String] = []

    private init() {}

    /// Conformance to AppLogger protocol
    public func log(_ message: String) {
        self.add(message)
    }

    public func add(_ message: String) {
        let timestamp = Date().formatted(.dateTime.hour().minute().second())
        
        Task { @MainActor in
            logs.insert("[\(timestamp)] \(message)", at: 0)
            if logs.count > 30 { logs.removeLast() }
            
            // Optional: Still print to console for local debugging
            #if DEBUG
            print("📝 [DebugLogger]: \(message)")
            #endif
        }
    }
}

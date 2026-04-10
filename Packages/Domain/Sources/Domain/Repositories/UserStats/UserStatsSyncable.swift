//
//  UserStatsSyncable.swift
//  Domain
//
//  Created by patrick ridd on 4/10/26.
//

import Foundation

/// A specialized interface for background syncing
public protocol UserStatsSyncable {
    func overwriteStats(userId: String, totalXP: Int, newStreak: Int, lastUpdated: Date) async throws
}

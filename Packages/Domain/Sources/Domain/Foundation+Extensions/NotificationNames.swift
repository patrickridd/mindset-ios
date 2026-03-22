//
//  NotificationNames.swift
//  Domain
//
//  Created by patrick ridd on 3/1/26.
//

import Foundation

public extension Notification.Name {
    /// Triggered when the app needs to re-initialize the root view/services
    static let restartApp = Notification.Name("com.mindset.notification.restartApp")
    
    /// Dispatched when any persistent data (Entry, UserProfile, etc.)
    /// is saved or deleted in the local store.
    public static let databaseDidChange = Notification.Name("com.mindset.notification.databaseDidChange")
}

//
//  HapticManager.swift
//  Core
//
//  Created by patrick ridd on 1/14/26.
//

import UIKit

@MainActor
public enum HapticManager {
    public static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    public static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

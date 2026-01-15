//
//  AppState.swift
//  Domain
//
//  Created by patrick ridd on 1/7/26.
//

/// AppState used for MainCoordinator Navigation
public enum AppState: Equatable {
    case onboarding
    case paywall
    case dashboard
    case mindset
    case ritualSuccess(archetype: String, xp: Int)
}

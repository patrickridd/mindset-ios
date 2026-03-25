//
//  StartDestination.swift
//  FeatureNavigation
//

import Foundation

/// Navigation destinations pushed from the pre-onboarding `StartView` stack (`MainCoordinator.startPath`).
public enum StartDestination: Hashable, Sendable {
    case onboarding
    case signIn
    case phoneSignIn
}

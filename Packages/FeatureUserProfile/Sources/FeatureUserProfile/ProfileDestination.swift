//
//  ProfileDestination.swift
//  FeatureUserProfile
//

/// Type-safe navigation destinations for the Profile tab's push stack.
///
/// Appended to `MainCoordinator.profilePath`
/// closures wired in `AppViewFactory`
public enum ProfileDestination: Hashable {
    case security
    case debugTools
}

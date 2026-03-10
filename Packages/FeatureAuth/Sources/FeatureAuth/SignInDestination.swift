//
//  SignInDestinations.swift
//  FeatureAuth
//
//  Created by patrick ridd on 3/9/26.
//


/// Type-safe navigation destinations for the SignInView's push stack.
///
/// Appended to `MainCoordinator.signInPath`
/// closures wired in `AppViewFactory`
public enum SignInDestination: Hashable {
    case phoneSignIn
}

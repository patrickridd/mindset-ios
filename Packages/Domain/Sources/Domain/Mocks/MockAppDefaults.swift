//
//  MockAppDefaults.swift
//  Domain
//

public final class MockAppDefaults: AppDefaults {
    public var onboardingComplete: Bool

    public init(onboardingComplete: Bool = false) {
        self.onboardingComplete = onboardingComplete
    }
}

//
//  OnboardingData.swift
//  Domain
//
//  Created by patrick ridd on 1/7/26.
//

public struct OnboardingData: Sendable {
    public var goal: String = ""
    public var overwhelmFrequency: String = ""
    public var bestSelfName: String = ""
    public var primaryGoal: String = ""
    
    public init(goal: String = "", overwhelmFrequency: String = "") {
        self.goal = goal
        self.overwhelmFrequency = overwhelmFrequency
    }
}

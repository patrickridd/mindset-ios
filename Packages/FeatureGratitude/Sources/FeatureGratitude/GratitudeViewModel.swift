//
//  GratitudeViewModel.swift
//  Presentation
//
//  Created by patrick ridd on 1/2/26.
//

import Foundation
import Domain
import Observation

@MainActor
@Observable
public final class GratitudeViewModel {
    // 1. Dependencies (Injected via Protocol/UseCase)
    private let getStreakUseCase: GetStreakUseCase
    
    // 2. UI State
    public var streakDisplay: String = "0"
    public var isLoading: Bool = false
    public var errorMessage: String?
    
    public init(useCase: GetStreakUseCase) {
        self.getStreakUseCase = useCase
    }
    
    // 3. Actions
    public func refreshStreak() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Call our Domain logic
            let streak = try await getStreakUseCase.execute()
            
            // Format for the UI (the "🔥" is a presentation detail!)
            self.streakDisplay = "\(streak) 🔥"
            
        } catch {
            self.errorMessage = "Failed to update streak"
        }
        
        isLoading = false
    }
}


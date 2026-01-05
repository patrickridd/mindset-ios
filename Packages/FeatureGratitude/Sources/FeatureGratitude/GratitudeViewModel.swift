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
    private let getStreakUseCase: GetStreakUseCase
    private let addGratitudeUseCase: AddGratitudeUseCase // <--- Add this
    
    public var streakDisplay: String = "0"
    public var entryText: String = "" // <--- For the TextField
    public var isLoading: Bool = false
    public var errorMessage: String? = nil

    public init(getStreakUseCase: GetStreakUseCase, addGratitudeUseCase: AddGratitudeUseCase) {
        self.getStreakUseCase = getStreakUseCase
        self.addGratitudeUseCase = addGratitudeUseCase
    }
    
    public func saveEntry() async {
        guard !entryText.isEmpty else { return }
        isLoading = true
        
        do {
            try await addGratitudeUseCase.execute(text: entryText)
            entryText = "" // Clear the field
            await refreshStreak() // Update the fire! 🔥
        } catch {
            print("Error saving: \(error)")
        }
        
        isLoading = false
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


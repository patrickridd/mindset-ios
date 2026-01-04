//
//  mindset_iosApp.swift
//  mindset-ios
//
//  Created by patrick ridd on 1/2/26.
//

import SwiftUI
import SwiftData
import Domain           // For the UseCase
import Data             // For the Repository Implementation
import FeatureGratitude // For the View and ViewModel

@main
struct mainApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // The Composition Root lives here
    let streakUseCase: GetStreakUseCase
    
    init() {
        // 1. Instantiate the plumbing (Data)
        let repo = SwiftDataGratitudeRepository()
        
        // 2. Instantiate the brain (Domain)
        self.streakUseCase = GetStreakUseCase(repository: repo)
    }
    
    var body: some Scene {
        WindowGroup {
            // THE COMPOSITION ROOT:
            // 1. Create Data implementation
            let repo = SwiftDataGratitudeRepository()
            
            // 2. Create Domain logic
            let useCase = GetStreakUseCase(repository: repo)
            
            // 3. Create Presentation logic
            let vm = GratitudeViewModel(streakUseCase: useCase)
            
            // 4. Return the View from the Feature module
            GratitudeView(viewModel: vm)
        }
        .modelContainer(sharedModelContainer)
    }
}

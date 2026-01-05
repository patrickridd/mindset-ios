//
//  mindset_iosApp.swift
//  mindset-ios
//
//  Created by patrick ridd on 1/2/26.
//

import SwiftUI
import SwiftData
import Domain
import Data
import FeatureGratitude

@main
struct MindsetApp: App {
    let container: ModelContainer
    let repository: SwiftDataGratitudeRepository
    let getStreakUseCase: GetStreakUseCase

    init() {
        do {
            // 2. Initialize the Schema (from your Data module)
            let schema = Schema([GratitudeEntryDB.self])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            
            self.container = try ModelContainer(for: schema, configurations: [config])
            
            // 3. Create the Repository (injecting the ModelContext)
            // We use the mainContext for the UI-driven repository
            self.repository = SwiftDataGratitudeRepository(modelContext: container.mainContext)
            
            // 4. Create the Use Case
            self.getStreakUseCase = GetStreakUseCase(repository: repository)
            
        } catch {
            fatalError("Could not initialize Mindset database: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            let addUseCase = AddGratitudeUseCase(repository: repository)
            let viewModel = GratitudeViewModel(getStreakUseCase: getStreakUseCase, addGratitudeUseCase: addUseCase)
            GratitudeView(viewModel: viewModel)
        }
        .modelContainer(container)
    }
}

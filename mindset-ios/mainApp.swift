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
import FeatureMindset

@main
struct MindsetApp: App {
    let container: ModelContainer
    let repository: SwiftDataMindsetRepository
    let getStreakUseCase: GetStreakUseCase

    init() {
        do {
            // Update the schema to use the new MindsetEntryDB
            let schema = Schema([MindsetEntryDB.self])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            
            self.container = try ModelContainer(for: schema, configurations: [config])
            self.repository = SwiftDataMindsetRepository(modelContext: container.mainContext)
            self.getStreakUseCase = GetStreakUseCase(repository: repository)

        } catch {
            fatalError("Could not initialize database.")
        }
    }

    var body: some Scene {
        WindowGroup {
            let ritualViewModel = MorningRitualViewModel(
                addMindsetUseCase: AddMindsetUseCase(repository: repository),
                getYesterdayBridgeUseCase: GetYesterdayBridgeUseCase(repository: repository)
            )
            MorningRitualView(viewModel: ritualViewModel)
        }
        .modelContainer(container)
    }
}

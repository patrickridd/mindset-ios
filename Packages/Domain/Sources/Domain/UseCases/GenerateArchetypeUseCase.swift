//
//  GenerateArchetypeUseCase.swift
//  Domain
//
//  Created by patrick ridd on 1/6/26.
//


// Domain/Sources/Domain/UseCases/GenerateArchetypeUseCase.swift

public struct GenerateArchetypeUseCase: Sendable {
    public init() {}
    
    public func execute(gratitude: String, goal: String) -> String {
        // Placeholder Logic: In the future, this calls an LLM or Sentiment Engine
        // For now, we'll detect keywords to demonstrate the "Physics"
        let combined = (gratitude + goal).lowercased()
        
        if combined.contains("build") || combined.contains("code") || combined.contains("structure") {
            return "The Architect"
        } else if combined.contains("rest") || combined.contains("peace") || combined.contains("calm") {
            return "The Essentialist"
        } else {
            return "The Resilient"
        }
    }
}
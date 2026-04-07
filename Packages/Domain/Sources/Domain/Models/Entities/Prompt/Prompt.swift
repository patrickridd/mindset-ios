//
//  Prompt.swift
//  Domain
//
//  Created by patrick ridd on 1/11/26.
//

public protocol Prompt: Sendable {
    var id: String { get }
    var category: PromptCategory { get }
    var headline: String { get }
    var questionText: String { get }
    var coachTip: String { get }
    var scientificRationale: String { get }
    var slots: [SlotMetadata] { get }
    var responseSlotCount: Int { get }
    var type: PromptType { get }
}

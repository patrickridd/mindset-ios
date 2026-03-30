//
//  Prompt.swift
//  Domain
//
//  Created by patrick ridd on 1/11/26.
//

public struct Prompt: Identifiable, Sendable {
    public let id: String
    public let category: PromptCategory
    public let headline: String
    /// e.g., "The Kindness Booster"
    public let questionText: String
    /// e.g., "What act of kindness did you perform today?"
    public let coachTip: String
    /// e.g., "Research suggests doing five small acts in one day for the biggest boost."
    public let scientificRationale: String
    /// Number of sequential answer slots for this prompt (one AI reflection runs after the last slot).
    public let responseSlotCount: Int

    public init(
        id: String,
        category: PromptCategory,
        headline: String,
        questionText: String,
        coachTip: String,
        scientificRationale: String,
        responseSlotCount: Int = 1
    ) {
        precondition(responseSlotCount >= 1, "responseSlotCount must be at least 1")
        self.id = id
        self.category = category
        self.headline = headline
        self.questionText = questionText
        self.coachTip = coachTip
        self.scientificRationale = scientificRationale
        self.responseSlotCount = responseSlotCount
    }

    // MARK: - Composite keys (multi-slot rituals)

    /// Separator between logical prompt id and slot index in persisted `PromptResponse.promptId` values.
    public static let compositeIdSeparator = "#"

    /// Storage key and persisted id for a specific slot under one logical prompt.
    public static func compositePromptId(baseId: String, slotIndex: Int) -> String {
        "\(baseId)\(compositeIdSeparator)\(slotIndex)"
    }

    /// Logical prompt id for AI and XP grouping; returns `id` unchanged if there is no slot suffix.
    public static func basePromptId(fromComposite compositeId: String) -> String {
        if let range = compositeId.range(of: compositeIdSeparator) {
            return String(compositeId[..<range.lowerBound])
        }
        return compositeId
    }
}

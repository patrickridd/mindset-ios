//
//  Prompt.swift
//  Domain
//
//  Created by patrick ridd on 1/11/26.
//

public typealias PromptID = String
public struct Prompt: Identifiable, Sendable {

    public let id: PromptID
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
        id: PromptID,
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

    // MARK: - Composite keys (multi-part prompt)

    /// Separator between logical prompt id and slot index in persisted `PromptResponse.promptId` values.
    public static let compositeIdSeparator = "#"

    /// Storage key and persisted id for a specific slot under one logical prompt.
    public static func compositePromptId(baseId: PromptID, slotIndex: Int) -> String {
        "\(baseId)\(compositeIdSeparator)\(slotIndex)"
    }

    /// Typed logical prompt id for AI and XP grouping. Returns `nil` for unknown ids.
    public static func basePromptID(fromComposite compositeId: String) -> PromptID? {
        if let range = compositeId.range(of: compositeIdSeparator) {
            return String(compositeId[..<range.lowerBound])
        }
        return compositeId
    }
}

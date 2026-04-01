import Domain
import Testing

@Suite("Prompt Catalog")
struct PromptCatalogTests {
    @Test("PromptDefinition ids map one-to-one")
    func promptDefinitionIDsAreUnique() {
        let ids = PromptDefinition.allCases.map(\.id)
        let unique = Set(ids)

        #expect(unique.count == ids.count)
        #expect(unique.count == PromptID.allCases.count)
    }

    @Test("PromptID raw values are unique")
    func promptIDRawValuesAreUnique() {
        let rawValues = PromptID.allCases.map(\.rawValue)
        let unique = Set(rawValues)
        #expect(unique.count == rawValues.count)
    }

    @Test("Morning template includes template todos with 3 slots")
    func morningTemplateIncludesTodos() {
        let prompts = PromptCatalog.morningStartTemplate()
        let todos = prompts.first { $0.id == .templateTodos }

        #expect(todos != nil)
        #expect(todos?.responseSlotCount == 3)
        #expect(todos?.category == .futureSelf)
    }

    @Test("Prompt lookup returns known prompt")
    func promptLookupByID() {
        let prompt = PromptCatalog.prompt(by: .gratitude01)

        #expect(prompt != nil)
        #expect(prompt?.id == .gratitude01)
        #expect(prompt?.category == .gratitude)
    }

    @Test("Category prompt definitions exclude templates and fallbacks")
    func categoryPromptDefinitionsContainOnlyPoolItems() {
        let allDefinitionCases = PromptCatalog.categoryPromptDefinitions.values.flatMap { $0 }

        #expect(!allDefinitionCases.isEmpty)
        #expect(allDefinitionCases.allSatisfy(\.isCategoryPool))
        #expect(!allDefinitionCases.contains(where: \.isMorningTemplate))
        #expect(!allDefinitionCases.contains(where: \.isFallback))
    }
}

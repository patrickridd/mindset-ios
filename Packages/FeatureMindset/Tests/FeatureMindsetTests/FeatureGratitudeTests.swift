import Testing
import Domain

@testable import FeatureMindset

@Suite("Prompt Presentation Resolver")
struct PromptPresentationResolverTests {
    private let resolver = PromptPresentationResolver()

    @Test("template todos routes to todayGoals")
    func templateTodosRoutesToTodayGoals() {
        let prompt = Prompt(
            id: .templateTodos,
            category: .futureSelf,
            headline: "Todos",
            questionText: "Question",
            coachTip: "Tip",
            scientificRationale: "Why",
            responseSlotCount: 3
        )

        #expect(resolver.presentationKind(for: prompt) == .todayGoals)
    }

    @Test("bestPossibleSelf routes to guidedVisualization")
    func bestPossibleSelfRoutesToGuided() {
        #expect(resolver.presentationKind(for: .bestPossibleSelf) == .guidedVisualization)
    }

    @Test("gratitude routes to default text entry")
    func gratitudeRoutesToDefault() {
        #expect(resolver.presentationKind(for: .gratitude) == .defaultTextEntry)
    }
}

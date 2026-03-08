import Domain
import Foundation
import Observation

@Observable
@MainActor
public final class AnalyzingViewModel {
    private let signInOrLinkUseCase: SignInOrLinkUseCase
    private let logger: AppLogger

    private var signInTask: Task<Void, Never>?

    public init(signInOrLinkUseCase: SignInOrLinkUseCase, logger: AppLogger) {
        self.signInOrLinkUseCase = signInOrLinkUseCase
        self.logger = logger
    }

    public func startIfNeeded() {
        guard signInTask == nil else { return }

        signInTask = Task { [signInOrLinkUseCase, logger] in
            logger.log("🧪 Onboarding analyzing started: attempting anonymous sign-in")
            guard !Task.isCancelled else { return }
            do {
                _ = try await signInOrLinkUseCase.execute(with: .anonymous)
            } catch {
                // Silent failure: coordinator will fall back to Auth after onboarding if needed.
                logger.log("⚠️ Onboarding anonymous sign-in failed: \(error.localizedDescription)")
            }
        }
    }

    public func waitForSignInIfStarted() async {
        await signInTask?.value
    }
}


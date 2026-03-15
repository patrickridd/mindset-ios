import Domain
import Foundation
import Observation

@Observable
public final class AnalyzingViewModel {
    private let signInService: SignInService
    private let logger: AppLogger

    private var signInTask: Task<Void, Never>?

    public init(signInService: SignInService, logger: AppLogger) {
        self.signInService = signInService
        self.logger = logger
    }

    public func startIfNeeded() {
        guard signInTask == nil else { return }

        signInTask = Task { [signInService, logger] in
            logger.log("🧪 Onboarding analyzing started: attempting anonymous sign-in")
            guard !Task.isCancelled else { return }
            do {
                _ = try await signInService.signIn(with: .anonymous)
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

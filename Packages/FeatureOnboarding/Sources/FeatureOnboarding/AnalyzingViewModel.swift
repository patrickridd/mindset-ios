import Domain
import Foundation
import Observation

@Observable
@MainActor
public final class AnalyzingViewModel {
    private let authService: AuthService
    private let logger: AppLogger

    private var signInTask: Task<Void, Never>?

    public init(authService: AuthService, logger: AppLogger) {
        self.authService = authService
        self.logger = logger
    }

    public func startIfNeeded() {
        guard signInTask == nil else { return }

        signInTask = Task { [authService, logger] in
            logger.log("🧪 Onboarding analyzing started: attempting anonymous sign-in")
            do {
                try await authService.signInAnonymously()
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


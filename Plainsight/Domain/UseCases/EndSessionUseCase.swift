import Foundation

/// Closes out a breathing session and persists it.
struct EndSessionUseCase: Sendable {
    let repository: BreathSessionRepository

    @discardableResult
    func execute(startTime: Date, endTime: Date, pattern: BreathPattern) async throws -> BreathSession {
        let session = BreathSession(startTime: startTime, endTime: endTime, pattern: pattern)
        try await repository.save(session)
        return session
    }
}

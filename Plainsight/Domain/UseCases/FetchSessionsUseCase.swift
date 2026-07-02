import Foundation

struct FetchSessionsUseCase: Sendable {
    let repository: BreathSessionRepository

    func execute() async throws -> [BreathSession] {
        try await repository.fetchAll()
    }
}

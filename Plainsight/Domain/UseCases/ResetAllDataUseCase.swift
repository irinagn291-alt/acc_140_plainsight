import Foundation

struct ResetAllDataUseCase: Sendable {
    let repository: BreathSessionRepository

    func execute() async throws {
        try await repository.deleteAll()
    }
}

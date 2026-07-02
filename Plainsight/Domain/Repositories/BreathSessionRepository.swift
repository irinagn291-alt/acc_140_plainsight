import Foundation

/// Abstraction over persistence for breathing sessions, so use cases never
/// depend on SwiftData directly.
protocol BreathSessionRepository: Sendable {
    func save(_ session: BreathSession) async throws
    func fetchAll() async throws -> [BreathSession]
    func deleteAll() async throws
}

import Foundation

@MainActor
@Observable
final class StatsViewModel {
    private(set) var stats: BreathStats = .empty
    private(set) var recentSessions: [BreathSession] = []
    private(set) var hasAnySession = false
    private(set) var isLoading = true

    private let dependencies: AppDependencies

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
    }

    func load() async {
        isLoading = true
        do {
            let sessions = try await dependencies.fetchSessionsUseCase.execute()
            hasAnySession = !sessions.isEmpty
            stats = dependencies.computeStatsUseCase.execute(sessions: sessions)
            recentSessions = Array(sessions.prefix(10))
        } catch {
            hasAnySession = false
            stats = .empty
            recentSessions = []
        }
        isLoading = false
    }
}

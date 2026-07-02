import Foundation
import SwiftData

/// Lightweight, manual DI container. No singletons — one instance is built
/// in `RootView` and threaded down through the view hierarchy.
@MainActor
final class AppDependencies {
    let repository: BreathSessionRepository
    let startSessionUseCase: StartSessionUseCase
    let endSessionUseCase: EndSessionUseCase
    let fetchSessionsUseCase: FetchSessionsUseCase
    let computeStatsUseCase: ComputeStatsUseCase
    let resetAllDataUseCase: ResetAllDataUseCase

    init(modelContext: ModelContext) {
        let repository = SwiftDataBreathSessionRepository(modelContext: modelContext)
        self.repository = repository
        self.startSessionUseCase = StartSessionUseCase()
        self.endSessionUseCase = EndSessionUseCase(repository: repository)
        self.fetchSessionsUseCase = FetchSessionsUseCase(repository: repository)
        self.computeStatsUseCase = ComputeStatsUseCase()
        self.resetAllDataUseCase = ResetAllDataUseCase(repository: repository)
    }
}

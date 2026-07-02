import Foundation
import SwiftData

/// Concrete `BreathSessionRepository` backed by SwiftData. Bound to the
/// main actor because `ModelContext` is not safe to share across threads.
@MainActor
final class SwiftDataBreathSessionRepository: BreathSessionRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func save(_ session: BreathSession) async throws {
        let model = BreathSessionModel(
            id: session.id,
            startTime: session.startTime,
            endTime: session.endTime,
            duration: session.duration,
            patternID: session.pattern.id,
            patternName: session.pattern.name,
            inhaleSeconds: session.pattern.inhaleSeconds,
            holdSeconds: session.pattern.holdSeconds,
            exhaleSeconds: session.pattern.exhaleSeconds
        )
        modelContext.insert(model)
        try modelContext.save()
    }

    func fetchAll() async throws -> [BreathSession] {
        let descriptor = FetchDescriptor<BreathSessionModel>(sortBy: [SortDescriptor(\.startTime, order: .reverse)])
        let models = try modelContext.fetch(descriptor)
        return models.map { model in
            BreathSession(
                id: model.id,
                startTime: model.startTime,
                endTime: model.endTime,
                pattern: BreathPattern(
                    id: model.patternID,
                    name: model.patternName,
                    inhaleSeconds: model.inhaleSeconds,
                    holdSeconds: model.holdSeconds,
                    exhaleSeconds: model.exhaleSeconds,
                    about: BreathPattern.pattern(forID: model.patternID).about
                )
            )
        }
    }

    func deleteAll() async throws {
        try modelContext.delete(model: BreathSessionModel.self)
        try modelContext.save()
    }
}

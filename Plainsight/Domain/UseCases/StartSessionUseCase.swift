import Foundation

/// Marks the beginning of a breathing session.
struct StartSessionUseCase: Sendable {
    func execute(now: Date = .now) -> Date {
        now
    }
}

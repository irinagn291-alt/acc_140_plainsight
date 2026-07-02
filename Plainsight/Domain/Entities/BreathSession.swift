import Foundation

/// A completed session of breathing practice.
struct BreathSession: Identifiable, Equatable, Sendable {
    let id: UUID
    let startTime: Date
    let endTime: Date
    let duration: TimeInterval
    let pattern: BreathPattern

    init(id: UUID = UUID(), startTime: Date, endTime: Date, pattern: BreathPattern) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.duration = endTime.timeIntervalSince(startTime)
        self.pattern = pattern
    }
}

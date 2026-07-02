import Foundation
import SwiftData

/// SwiftData mirror of `BreathSession`. Kept free of business logic;
/// mapping to/from the domain entity lives in the repository.
@Model
final class BreathSessionModel {
    @Attribute(.unique) var id: UUID
    var startTime: Date
    var endTime: Date
    var duration: TimeInterval
    var patternID: String
    var patternName: String
    var inhaleSeconds: TimeInterval
    var holdSeconds: TimeInterval
    var exhaleSeconds: TimeInterval

    init(
        id: UUID,
        startTime: Date,
        endTime: Date,
        duration: TimeInterval,
        patternID: String,
        patternName: String,
        inhaleSeconds: TimeInterval,
        holdSeconds: TimeInterval,
        exhaleSeconds: TimeInterval
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
        self.patternID = patternID
        self.patternName = patternName
        self.inhaleSeconds = inhaleSeconds
        self.holdSeconds = holdSeconds
        self.exhaleSeconds = exhaleSeconds
    }
}

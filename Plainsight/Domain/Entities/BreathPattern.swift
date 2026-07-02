import Foundation

/// Describes the timing of one inhale-hold-exhale cycle.
struct BreathPattern: Identifiable, Equatable, Sendable {
    let id: String
    let name: String
    let inhaleSeconds: TimeInterval
    let holdSeconds: TimeInterval
    let exhaleSeconds: TimeInterval
    /// One quiet sentence about when this practice helps.
    let about: String

    var cycleDuration: TimeInterval {
        inhaleSeconds + holdSeconds + exhaleSeconds
    }

    func duration(of phase: BreathPhase) -> TimeInterval {
        switch phase {
        case .inhale: return inhaleSeconds
        case .hold: return holdSeconds
        case .exhale: return exhaleSeconds
        }
    }

    /// Compact "4 · 2 · 6" style timing summary for lists.
    var timingLabel: String {
        [inhaleSeconds, holdSeconds, exhaleSeconds]
            .map { $0.truncatingRemainder(dividingBy: 1) == 0 ? String(Int($0)) : String($0) }
            .joined(separator: " · ")
    }

    /// The default pattern, available to every user, forever.
    static let calm = BreathPattern(
        id: "calm", name: "Calm",
        inhaleSeconds: 4, holdSeconds: 2, exhaleSeconds: 6,
        about: "A long exhale for everyday downshifting. Good anytime."
    )

    static let box = BreathPattern(
        id: "box", name: "Box",
        inhaleSeconds: 4, holdSeconds: 4, exhaleSeconds: 4,
        about: "Even sides, steady mind. Useful before focused work."
    )
    static let deepRelief = BreathPattern(
        id: "deepRelief", name: "Deep Relief",
        inhaleSeconds: 4, holdSeconds: 7, exhaleSeconds: 8,
        about: "The 4-7-8 rhythm. For anxiety spikes and falling asleep."
    )
    static let coherent = BreathPattern(
        id: "coherent", name: "Coherent",
        inhaleSeconds: 5.5, holdSeconds: 0, exhaleSeconds: 5.5,
        about: "Slow, even waves at about five breaths a minute."
    )
    static let ground = BreathPattern(
        id: "ground", name: "Ground",
        inhaleSeconds: 3, holdSeconds: 0, exhaleSeconds: 5,
        about: "A short, simple reset when there's no time for more."
    )
    static let unwind = BreathPattern(
        id: "unwind", name: "Unwind",
        inhaleSeconds: 4, holdSeconds: 4, exhaleSeconds: 8,
        about: "A long release for the end of the day."
    )

    static let all: [BreathPattern] = [.calm, .box, .deepRelief, .coherent, .ground, .unwind]

    static func pattern(forID id: String) -> BreathPattern {
        all.first { $0.id == id } ?? .calm
    }
}

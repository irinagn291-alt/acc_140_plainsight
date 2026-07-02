import Foundation

/// A single generated drone used as the optional ambient backdrop to a session.
/// No track library, ever — just a frequency and a name.
struct AmbientTone: Identifiable, Equatable, Sendable {
    let id: String
    let name: String
    let frequency: Double

    static let calm = AmbientTone(id: "calm", name: "Calm", frequency: 110)
    static let night = AmbientTone(id: "night", name: "Night", frequency: 60)
    static let dusk = AmbientTone(id: "dusk", name: "Dusk", frequency: 144)

    static let all: [AmbientTone] = [.calm, .night, .dusk]

    static func tone(forID id: String) -> AmbientTone {
        all.first { $0.id == id } ?? .calm
    }
}

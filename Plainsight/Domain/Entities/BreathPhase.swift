import Foundation

/// A single phase within one breathing cycle.
enum BreathPhase: String, Sendable {
    case inhale
    case hold
    case exhale

    var label: String {
        switch self {
        case .inhale: return "Inhale"
        case .hold: return "Hold"
        case .exhale: return "Exhale"
        }
    }
}

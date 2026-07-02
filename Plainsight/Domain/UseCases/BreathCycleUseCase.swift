import Foundation

/// Pure timing logic for the inhale-hold-exhale cycle. Stateless: given an
/// elapsed time it tells the caller which phase is active and how far the
/// breather has progressed through it. Driven by `BreathViewModel`'s timer.
struct BreathCycleUseCase: Sendable {
    let pattern: BreathPattern

    /// The phase active at `elapsedInCycle` seconds into one cycle.
    func phase(at elapsedInCycle: TimeInterval) -> BreathPhase {
        if elapsedInCycle < pattern.inhaleSeconds {
            return .inhale
        } else if elapsedInCycle < pattern.inhaleSeconds + pattern.holdSeconds {
            return .hold
        } else {
            return .exhale
        }
    }

    /// Progress (0...1) through the currently active phase.
    func phaseProgress(at elapsedInCycle: TimeInterval) -> Double {
        let phase = phase(at: elapsedInCycle)
        let phaseStart: TimeInterval
        switch phase {
        case .inhale: phaseStart = 0
        case .hold: phaseStart = pattern.inhaleSeconds
        case .exhale: phaseStart = pattern.inhaleSeconds + pattern.holdSeconds
        }
        let duration = pattern.duration(of: phase)
        guard duration > 0 else { return 1 }
        return min(max((elapsedInCycle - phaseStart) / duration, 0), 1)
    }

    /// Circle scale (0.55...1.0) for the given moment, used to animate the breathing circle.
    func circleScale(at elapsedInCycle: TimeInterval) -> Double {
        let phase = phase(at: elapsedInCycle)
        let progress = phaseProgress(at: elapsedInCycle)
        let minScale = 0.55
        let maxScale = 1.0
        switch phase {
        case .inhale: return minScale + (maxScale - minScale) * progress
        case .hold: return maxScale
        case .exhale: return maxScale - (maxScale - minScale) * progress
        }
    }

    func elapsedInCycle(totalElapsed: TimeInterval) -> TimeInterval {
        guard pattern.cycleDuration > 0 else { return 0 }
        return totalElapsed.truncatingRemainder(dividingBy: pattern.cycleDuration)
    }
}

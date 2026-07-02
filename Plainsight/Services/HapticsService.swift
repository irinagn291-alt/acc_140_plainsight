import CoreHaptics
import UIKit

/// Stateless namespace for the breathing-rhythm haptics. Uses Core Haptics
/// where supported, falling back to `UIImpactFeedbackGenerator` everywhere
/// else (e.g. the simulator).
enum HapticsService {
    private static let supportsCoreHaptics: Bool = CHHapticEngine.capabilitiesForHardware().supportsHaptics

    @MainActor private static var engine: CHHapticEngine?
    @MainActor private static let fallbackGenerator = UIImpactFeedbackGenerator(style: .soft)

    @MainActor
    static func prepareEngine() {
        guard supportsCoreHaptics else { return }
        guard engine == nil else { return }
        do {
            let newEngine = try CHHapticEngine()
            newEngine.resetHandler = { [weak newEngine] in
                try? newEngine?.start()
            }
            newEngine.stoppedHandler = { _ in }
            try newEngine.start()
            engine = newEngine
        } catch {
            engine = nil
        }
    }

    /// A gently rising continuous pulse for the inhale.
    @MainActor
    static func playInhale(duration: TimeInterval) {
        playContinuous(startIntensity: 0.15, endIntensity: 0.55, duration: duration)
    }

    /// A steady soft pulse held during the breath hold.
    @MainActor
    static func playHold() {
        playTransient(intensity: 0.35, sharpness: 0.2)
    }

    /// A gently falling continuous pulse for the exhale.
    @MainActor
    static func playExhale(duration: TimeInterval) {
        playContinuous(startIntensity: 0.55, endIntensity: 0.1, duration: duration)
    }

    /// The soft final vibration marking the end of a session.
    @MainActor
    static func playSessionEnd() {
        guard supportsCoreHaptics, let engine else {
            fallbackGenerator.impactOccurred(intensity: 0.4)
            return
        }
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.1)
            ],
            relativeTime: 0
        )
        play(events: [event], engine: engine)
    }

    @MainActor
    private static func playTransient(intensity: Float, sharpness: Float) {
        guard supportsCoreHaptics, let engine else {
            fallbackGenerator.impactOccurred(intensity: CGFloat(intensity))
            return
        }
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            ],
            relativeTime: 0
        )
        play(events: [event], engine: engine)
    }

    @MainActor
    private static func playContinuous(startIntensity: Float, endIntensity: Float, duration: TimeInterval) {
        guard supportsCoreHaptics, let engine, duration > 0 else {
            fallbackGenerator.impactOccurred(intensity: CGFloat(max(startIntensity, endIntensity)))
            return
        }
        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: startIntensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.1)
            ],
            relativeTime: 0,
            duration: duration
        )
        let curve = CHHapticParameterCurve(
            parameterID: .hapticIntensityControl,
            controlPoints: [
                CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: startIntensity),
                CHHapticParameterCurve.ControlPoint(relativeTime: duration, value: endIntensity)
            ],
            relativeTime: 0
        )
        play(events: [event], curves: [curve], engine: engine)
    }

    @MainActor
    private static func play(events: [CHHapticEvent], curves: [CHHapticParameterCurve] = [], engine: CHHapticEngine) {
        do {
            let pattern = try CHHapticPattern(events: events, parameterCurves: curves)
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            fallbackGenerator.impactOccurred(intensity: 0.3)
        }
    }
}

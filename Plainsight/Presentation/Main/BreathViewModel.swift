import Foundation
import SwiftUI

@MainActor
@Observable
final class BreathViewModel {
    private static let durationRange: ClosedRange<Double> = 1...10
    private static let oneBreathDuration: TimeInterval = 30
    private static let tickInterval: UInt64 = 33_000_000 // ~30fps

    private(set) var phase: BreathPhase = .inhale
    private(set) var circleScale: Double = 0.55
    private(set) var isSessionActive = false
    private(set) var isFadingOut = false
    private(set) var selectedDurationMinutes: Double = 3
    private static let idleStatusText = "Long-press to begin"

    private(set) var statusText: String = BreathViewModel.idleStatusText

    var ambientToneEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "ambientToneEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "ambientToneEnabled") }
    }

    /// Name of the practice that the next session will use, for the main-screen chip.
    var activePatternName: String { activePattern.name }

    /// The pattern actually used for the next session.
    private var activePattern: BreathPattern {
        BreathPattern.pattern(forID: UserDefaults.standard.string(forKey: "selectedPatternID") ?? BreathPattern.calm.id)
    }

    private var activeTone: AmbientTone {
        AmbientTone.tone(forID: UserDefaults.standard.string(forKey: "selectedToneID") ?? AmbientTone.calm.id)
    }

    private let dependencies: AppDependencies
    private let ambientService = AmbientToneService()
    private var cycleUseCase = BreathCycleUseCase(pattern: .calm)
    private var sessionPattern = BreathPattern.calm

    private var sessionTask: Task<Void, Never>?
    private var sessionStartTime: Date?
    private var sessionDuration: TimeInterval = 0
    private var lastPhase: BreathPhase?
    private var dragBaseDuration: Double?

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        HapticsService.prepareEngine()
    }

    func dragChanged(translationHeight: CGFloat) {
        guard !isSessionActive else { return }
        if dragBaseDuration == nil { dragBaseDuration = selectedDurationMinutes }
        let delta = -translationHeight / 40.0
        let candidate = (dragBaseDuration ?? selectedDurationMinutes) + Double(delta)
        selectedDurationMinutes = candidate.rounded().clamped(to: Self.durationRange)
        statusText = "\(Int(selectedDurationMinutes)) min — release, then press"
    }

    func dragEnded() {
        dragBaseDuration = nil
        if !isSessionActive {
            statusText = Self.idleStatusText
        }
    }

    func startSession() {
        startSession(duration: selectedDurationMinutes * 60)
    }

    func startOneBreath() {
        startSession(duration: Self.oneBreathDuration)
    }

    func endSessionEarly() {
        guard isSessionActive else { return }
        finishSession()
    }

    private func startSession(duration: TimeInterval) {
        guard !isSessionActive else { return }
        isSessionActive = true
        isFadingOut = false
        sessionDuration = duration
        sessionPattern = activePattern
        cycleUseCase = BreathCycleUseCase(pattern: sessionPattern)
        sessionStartTime = dependencies.startSessionUseCase.execute()
        lastPhase = nil
        statusText = ""

        if ambientToneEnabled {
            ambientService.start(tone: activeTone)
        }

        sessionTask = Task { [weak self] in
            await self?.runSessionLoop()
        }
    }

    private func runSessionLoop() async {
        guard let start = sessionStartTime else { return }
        while !Task.isCancelled {
            let elapsed = Date.now.timeIntervalSince(start)
            if elapsed >= sessionDuration {
                finishSession()
                return
            }
            update(elapsed: elapsed)
            try? await Task.sleep(nanoseconds: Self.tickInterval)
        }
    }

    private func update(elapsed: TimeInterval) {
        let elapsedInCycle = cycleUseCase.elapsedInCycle(totalElapsed: elapsed)
        let currentPhase = cycleUseCase.phase(at: elapsedInCycle)
        circleScale = cycleUseCase.circleScale(at: elapsedInCycle)
        phase = currentPhase

        if currentPhase != lastPhase {
            lastPhase = currentPhase
            switch currentPhase {
            case .inhale: HapticsService.playInhale(duration: sessionPattern.inhaleSeconds)
            case .hold: HapticsService.playHold()
            case .exhale: HapticsService.playExhale(duration: sessionPattern.exhaleSeconds)
            }
        }
    }

    private func finishSession() {
        guard isSessionActive, let start = sessionStartTime else { return }
        sessionTask?.cancel()
        sessionTask = nil
        isFadingOut = true
        ambientService.stop()
        HapticsService.playSessionEnd()

        let endTime = Date.now
        Task { [weak self] in
            try? await self?.dependencies.endSessionUseCase.execute(startTime: start, endTime: endTime, pattern: self?.sessionPattern ?? .calm)
        }

        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 1_600_000_000)
            self?.resetAfterSession()
        }
    }

    private func resetAfterSession() {
        isSessionActive = false
        isFadingOut = false
        circleScale = 0.55
        phase = .inhale
        sessionStartTime = nil
        statusText = Self.idleStatusText
    }
}

private extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

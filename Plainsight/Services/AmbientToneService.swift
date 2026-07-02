import AVFoundation

/// No track library, ever — just a single quiet, generated ambient tone
/// that can be faded in and out during a session.
@MainActor
final class AmbientToneService {
    private let engine = AVAudioEngine()
    private var sourceNode: AVAudioSourceNode?
    private var phase: Double = 0
    private var currentAmplitude: Double = 0
    private var targetAmplitude: Double = 0
    private var isRunning = false
    private var frequency: Double = AmbientTone.calm.frequency

    func start(tone: AmbientTone = .calm) {
        guard !isRunning else { return }
        frequency = tone.frequency
        let sampleRate = engine.outputNode.outputFormat(forBus: 0).sampleRate
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)

        let node = AVAudioSourceNode { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            guard let self else { return noErr }
            let buffers = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let phaseIncrement = 2 * Double.pi * self.frequency / sampleRate

            for frame in 0..<Int(frameCount) {
                self.currentAmplitude += (self.targetAmplitude - self.currentAmplitude) * 0.001
                let sample = Float(sin(self.phase) * self.currentAmplitude)
                self.phase += phaseIncrement
                if self.phase > 2 * Double.pi { self.phase -= 2 * Double.pi }
                for buffer in buffers {
                    let bufferPointer = UnsafeMutableBufferPointer<Float>(buffer)
                    bufferPointer[frame] = sample
                }
            }
            return noErr
        }

        engine.attach(node)
        engine.connect(node, to: engine.mainMixerNode, format: format)
        sourceNode = node

        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            try engine.start()
            isRunning = true
            targetAmplitude = 0.06
        } catch {
            isRunning = false
        }
    }

    func stop() {
        guard isRunning else { return }
        targetAmplitude = 0
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 800_000_000)
            self?.teardown()
        }
    }

    private func teardown() {
        engine.stop()
        if let sourceNode {
            engine.detach(sourceNode)
        }
        sourceNode = nil
        isRunning = false
        phase = 0
        currentAmplitude = 0
    }
}

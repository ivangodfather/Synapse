import AVFoundation

@MainActor
final class SoundManager {
    static let shared = SoundManager()
    private var audioEngine: AVAudioEngine
    private var playerNode: AVAudioPlayerNode

    private init() {
        audioEngine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()
        audioEngine.attach(playerNode)

        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: format)

        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            try audioEngine.start()
        } catch {
            print("Audio engine failed to start: \(error)")
        }
    }

    // MARK: - Tone Generation

    /// Play a tone based on cell position in the grid
    /// Creates a unique pitch per cell for audio-aided memory
    func playCellTone(cellIndex: Int, gridSize: Int) {
        // Pentatonic scale — always sounds pleasant
        let baseFrequencies: [Double] = [
            261.63, // C4
            293.66, // D4
            329.63, // E4
            392.00, // G4
            440.00, // A4
            523.25, // C5
            587.33, // D5
            659.25, // E5
            783.99, // G5
            880.00, // A5
            1046.50, // C6
            1174.66, // D6
            1318.51, // E6
            1567.98, // G6
            1760.00, // A6
            2093.00, // C7
            2349.32, // D7
            2637.02, // E7
            2959.96, // G7
            3135.96, // A7
            3520.00, // C8
            3951.07, // D8
            4186.01, // E8
            4698.64, // G8
            5274.04, // A8
        ]

        let index = min(cellIndex, baseFrequencies.count - 1)
        let frequency = baseFrequencies[index]
        playTone(frequency: frequency, duration: 0.25, volume: 0.3)
    }

    /// Correct tap — bright ascending blip
    func playCorrectTap() {
        playTone(frequency: 880, duration: 0.1, volume: 0.25)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            self.playTone(frequency: 1108.73, duration: 0.12, volume: 0.2)
        }
    }

    /// Wrong tap — low dissonant buzz
    func playWrongTap() {
        playTone(frequency: 150, duration: 0.35, volume: 0.35, waveform: .sawtooth)
    }

    /// Round complete — quick celebratory arpeggio
    func playRoundComplete() {
        let notes: [(Double, Double)] = [
            (523.25, 0.0),   // C5
            (659.25, 0.08),  // E5
            (783.99, 0.16),  // G5
            (1046.50, 0.24), // C6
        ]
        for (freq, delay) in notes {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.playTone(frequency: freq, duration: 0.15, volume: 0.2)
            }
        }
    }

    /// Game over — descending sad tones
    func playGameOver() {
        let notes: [(Double, Double)] = [
            (440.0, 0.0),    // A4
            (349.23, 0.2),   // F4
            (293.66, 0.4),   // D4
            (220.0, 0.6),    // A3
        ]
        for (freq, delay) in notes {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.playTone(frequency: freq, duration: 0.3, volume: 0.25, waveform: .sine)
            }
        }
    }

    // MARK: - Private

    private enum Waveform {
        case sine
        case sawtooth
    }

    private func playTone(frequency: Double, duration: Double, volume: Float, waveform: Waveform = .sine) {
        let sampleRate: Double = 44100
        let frameCount = AVAudioFrameCount(sampleRate * duration)

        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1),
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }

        buffer.frameLength = frameCount
        guard let floatData = buffer.floatChannelData?[0] else { return }

        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            let phase = 2.0 * Double.pi * frequency * t

            var sample: Double
            switch waveform {
            case .sine:
                sample = sin(phase)
            case .sawtooth:
                sample = 2.0 * (frequency * t - floor(0.5 + frequency * t))
            }

            // Envelope: quick attack, smooth release
            let envelope: Double
            let attackSamples = Int(sampleRate * 0.01)
            let releaseSamples = Int(sampleRate * 0.05)
            let releaseStart = Int(frameCount) - releaseSamples

            if i < attackSamples {
                envelope = Double(i) / Double(attackSamples)
            } else if i > releaseStart {
                envelope = Double(Int(frameCount) - i) / Double(releaseSamples)
            } else {
                envelope = 1.0
            }

            floatData[i] = Float(sample * envelope) * volume
        }

        playerNode.stop()
        playerNode.scheduleBuffer(buffer, completionHandler: nil)
        playerNode.play()
    }
}

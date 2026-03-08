//
//  TunerEngine.swift
//  Tune
//
//  Created by Brian O'Byrne on 2/25/26.
//

import AudioKit
import SoundpipeAudioKit
import Foundation
import Observation

@Observable
class TunerEngine {

    // MARK: - Public State

    var frequency: Float = 0
    var noteNameWithSharps: String = "--"
    var noteNameWithFlats: String = "--"
    var octave: Int = 0
    var cents: Double = 0
    var isRunning: Bool = false
    var error: Error?
    var referencePitch: Float = 440.0

    // MARK: - Private Constants

    private static let noteNameSharps = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    private static let noteNamesFlats  = ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"]

    // MARK: - Audio

    private let engine = AudioEngine()
    private var tracker: PitchTap?

    // MARK: - Smoothing & Silence

    private var smoothedFrequency: Float = 0
    private var smoothedCentsValue: Double = 0
    private let frequencySmoothingFactor: Float = 0.25
    private let centsSmoothingFactor: Double = 0.2
    private var silenceTimer: Timer?

    // MARK: - Lifecycle

    func start() {
        guard let input = engine.input else {
            error = TunerError.microphoneUnavailable
            return
        }

        let silencer = Mixer(input)
        silencer.volume = 0
        engine.output = silencer

        tracker = PitchTap(input) { [weak self] pitch, amp in
            guard amp[0] > 0.05, pitch[0] > 20 else { return }
            let freq = pitch[0]
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.smoothedFrequency = self.frequencySmoothingFactor * freq
                    + (1 - self.frequencySmoothingFactor) * self.smoothedFrequency
                self.resetSilenceTimer()
                self.update(frequency: self.smoothedFrequency)
            }
        }

        do {
            try engine.start()
            tracker?.start()
            isRunning = true
            error = nil
        } catch {
            self.error = error
        }
    }

    func stop() {
        tracker?.stop()
        engine.stop()
        silenceTimer?.invalidate()
        silenceTimer = nil
        isRunning = false
    }

    // MARK: - Pitch Processing

    func update(frequency: Float) {
        self.frequency = frequency
        let exactMidi = 12 * log2(Double(frequency) / Double(referencePitch)) + 69
        let nearestMidi = round(exactMidi)
        let rawCents = (exactMidi - nearestMidi) * 100
        smoothedCentsValue = centsSmoothingFactor * rawCents
            + (1 - centsSmoothingFactor) * smoothedCentsValue
        cents = smoothedCentsValue
        let midiInt = Int(nearestMidi)
        octave = (midiInt / 12) - 1
        noteNameWithSharps = Self.noteNameSharps[((midiInt % 12) + 12) % 12]
        noteNameWithFlats  = Self.noteNamesFlats[((midiInt % 12) + 12) % 12]
    }

    // MARK: - Private

    private func resetSilenceTimer() {
        silenceTimer?.invalidate()
        silenceTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { [weak self] (_: Timer) in
            guard let self else { return }
            self.frequency = 0
            self.cents = 0
            self.smoothedFrequency = 0
            self.smoothedCentsValue = 0
            self.noteNameWithSharps = "--"
            self.noteNameWithFlats = "--"
        }
    }
}

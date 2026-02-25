//
//  TunerEngine.swift
//  Tune
//
//  Created by Brian O'Byrne on 2/25/26.
//

import AudioKit
import SoundpipeAudioKit
import Observation

import SwiftUI

@Observable
class TunerEngine {
    var frequency: Float = 0
    var noteNameWithSharps: String = "--"
    var noteNameWithFlats: String = "--"
    var octave: Int = 0

    private let engine = AudioEngine()
    private var tracker: PitchTap?

    func start() throws {
        guard let input = engine.input else { return }
        let silencer = Mixer(input)
        silencer.volume = 0
        engine.output = silencer

        tracker = PitchTap(input) { [weak self] pitch, amp in
            guard amp[0] > 0.05, pitch[0] > 20 else { return }
            let freq = pitch[0]
            DispatchQueue.main.async { [weak self] in
                self?.update(frequency: freq)
            }
        }

        try engine.start()
        tracker?.start()
    }

    func stop() {
        tracker?.stop()
        engine.stop()
    }

    func update(frequency: Float) {
        self.frequency = frequency
        let noteNameSharps = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let noteNamesFlats = ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"]
        let midi = Int(round(12 * log2(Double(frequency) / 440.0))) + 69
        octave = (midi / 12) - 1
        noteNameWithSharps = noteNameSharps[((midi % 12) + 12) % 12]
        noteNameWithFlats = noteNamesFlats[((midi % 12) + 12) % 12]
    }
}

//
//  TuneTests.swift
//  TuneTests
//
//  Created by Brian O'Byrne on 2/25/26.
//

import Testing
import SwiftUI
@testable import Tune

// MARK: - TunerEngine: Initial State

struct TunerEngineTests {

    @Test func initialState() {
        let engine = TunerEngine()
        #expect(engine.frequency == 0)
        #expect(engine.noteNameWithSharps == "--")
        #expect(engine.noteNameWithFlats == "--")
        #expect(engine.octave == 0)
    }

    @Test func initialCentsAndRunningState() {
        let engine = TunerEngine()
        #expect(engine.cents == 0)
        #expect(engine.isRunning == false)
        #expect(engine.error == nil)
        #expect(engine.referencePitch == 440.0)
    }

    // MARK: - Note Name & Octave

    @Test func a4() {
        let engine = TunerEngine()
        engine.update(frequency: 440.0)
        #expect(engine.noteNameWithSharps == "A")
        #expect(engine.noteNameWithFlats == "A")
        #expect(engine.octave == 4)
        #expect(engine.frequency == 440.0)
    }

    @Test func c4() {
        let engine = TunerEngine()
        engine.update(frequency: 261.63)
        #expect(engine.noteNameWithSharps == "C")
        #expect(engine.noteNameWithFlats == "C")
        #expect(engine.octave == 4)
    }

    @Test func c5() {
        let engine = TunerEngine()
        engine.update(frequency: 523.25)
        #expect(engine.noteNameWithSharps == "C")
        #expect(engine.noteNameWithFlats == "C")
        #expect(engine.octave == 5)
    }

    @Test func gSharp4() {
        let engine = TunerEngine()
        engine.update(frequency: 415.30)
        #expect(engine.noteNameWithSharps == "G#")
        #expect(engine.noteNameWithFlats == "Ab")
        #expect(engine.octave == 4)
    }

    @Test func b4() {
        let engine = TunerEngine()
        engine.update(frequency: 493.88)
        #expect(engine.noteNameWithSharps == "B")
        #expect(engine.noteNameWithFlats == "B")
        #expect(engine.octave == 4)
    }

    @Test func dSharp4() {
        let engine = TunerEngine()
        engine.update(frequency: 311.13)
        #expect(engine.noteNameWithSharps == "D#")
        #expect(engine.noteNameWithFlats == "Eb")
        #expect(engine.octave == 4)
    }

    @Test func frequencyIsStored() {
        let engine = TunerEngine()
        engine.update(frequency: 329.63)
        #expect(engine.frequency == 329.63)
    }

    // MARK: - Octave Edge Cases

    @Test func c3octave() {
        let engine = TunerEngine()
        engine.update(frequency: 130.81)
        #expect(engine.noteNameWithSharps == "C")
        #expect(engine.octave == 3)
    }

    @Test func c6octave() {
        let engine = TunerEngine()
        engine.update(frequency: 1046.50)
        #expect(engine.noteNameWithSharps == "C")
        #expect(engine.octave == 6)
    }

    // MARK: - Cents
    //
    // TunerEngine applies an exponential moving average (EMA) to cents:
    //   smoothed = 0.2 * raw + 0.8 * previous
    // A single update from a cold start (previous = 0) only reaches 20% of the
    // true value. Tests that assert a meaningful cents deviation must call
    // update() repeatedly to let the EMA converge toward the real reading.

    @Test func centsForPerfectA4IsZero() {
        let engine = TunerEngine()
        engine.update(frequency: 440.0)
        #expect(abs(engine.cents) < 0.01)
    }

    @Test func centsPositiveForSharpNote() {
        // A4 + 25 cents ≈ 446.37 Hz; EMA must converge over multiple updates
        let engine = TunerEngine()
        for _ in 0..<20 { engine.update(frequency: 446.37) }
        #expect(engine.cents > 20 && engine.cents < 30)
    }

    @Test func centsNegativeForFlatNote() {
        // A4 − 25 cents ≈ 433.93 Hz; EMA must converge over multiple updates
        let engine = TunerEngine()
        for _ in 0..<20 { engine.update(frequency: 433.93) }
        #expect(engine.cents < -20 && engine.cents > -30)
    }

    @Test func centsRangeClampedToHalfSemitone() {
        // A note exactly halfway between A4 and Bb4 should read ~50 cents
        let engine = TunerEngine()
        engine.update(frequency: 452.89)
        #expect(abs(engine.cents) <= 50)
    }

    @Test func centsConvergeTowardTrueValueOverMultipleUpdates() {
        // EMA smoothing: repeated updates with the same frequency should
        // converge cents toward the true value
        let engine = TunerEngine()
        for _ in 0..<20 {
            engine.update(frequency: 446.37) // ~+25¢ sharp
        }
        #expect(engine.cents > 23 && engine.cents < 27)
    }

    // MARK: - Stop

    @Test func stopSetsIsRunningFalse() {
        let engine = TunerEngine()
        engine.stop()
        #expect(engine.isRunning == false)
    }

    // MARK: - Reference Pitch

    @Test func referencePitchAffectsCents() {
        let engine = TunerEngine()
        engine.referencePitch = 442.0
        // 440 Hz is flat relative to an A442 reference; converge EMA first
        for _ in 0..<20 { engine.update(frequency: 440.0) }
        #expect(engine.cents < -5)
    }

    @Test func referencePitchDoesNotChangeNoteName() {
        let engine = TunerEngine()
        engine.referencePitch = 442.0
        engine.update(frequency: 440.0)
        #expect(engine.noteNameWithSharps == "A")
        #expect(engine.octave == 4)
    }

    @Test func referencePitch432CentsForA4() {
        let engine = TunerEngine()
        engine.referencePitch = 432.0
        engine.update(frequency: 432.0)
        #expect(abs(engine.cents) < 0.01)
    }

    @Test func referencePitchSharpRelativeToLower() {
        // 440 Hz is sharp relative to A432 reference
        let engine = TunerEngine()
        engine.referencePitch = 432.0
        engine.update(frequency: 440.0)
        #expect(engine.cents > 5)
    }
}

// MARK: - TunerUtilities

struct TunerUtilitiesTests {

    // MARK: - tuningAccuracyColor

    @Test func tuningAccuracyColorInTune() {
        // < 5¢ → green
        #expect(0.0.tuningAccuracyColor == .green)
        #expect(4.9.tuningAccuracyColor == .green)
        #expect((-4.9).tuningAccuracyColor == .green)
    }

    @Test func tuningAccuracyColorSlightlyOff() {
        // 5¢ – 19¢ → yellow
        #expect(5.0.tuningAccuracyColor == .yellow)
        #expect(19.9.tuningAccuracyColor == .yellow)
        #expect((-10.0).tuningAccuracyColor == .yellow)
    }

    @Test func tuningAccuracyColorFarOff() {
        // ≥ 20¢ → red
        #expect(20.0.tuningAccuracyColor == .red)
        #expect(50.0.tuningAccuracyColor == .red)
        #expect((-35.0).tuningAccuracyColor == .red)
    }

    // MARK: - formattedCentsLabel

    @Test func formattedCentsLabelInTune() {
        #expect(0.0.formattedCentsLabel == "in tune")
        #expect(0.4.formattedCentsLabel == "in tune")
        #expect((-0.4).formattedCentsLabel == "in tune")
    }

    @Test func formattedCentsLabelPositive() {
        #expect(10.0.formattedCentsLabel == "+10¢")
        #expect(25.0.formattedCentsLabel == "+25¢")
    }

    @Test func formattedCentsLabelNegative() {
        #expect((-10.0).formattedCentsLabel == "-10¢")
        #expect((-50.0).formattedCentsLabel == "-50¢")
    }

    // MARK: - formattedFrequency

    @Test func formattedFrequency() {
        #expect(Float(440.0).formattedFrequency == "440.0 Hz")
        #expect(Float(261.63).formattedFrequency == "261.6 Hz")
        #expect(Float(1000.0).formattedFrequency == "1000.0 Hz")
    }
}

// MARK: - TunerError

struct TunerErrorTests {

    @Test func microphoneUnavailableDescription() {
        let error = TunerError.microphoneUnavailable
        #expect(error.errorDescription == "Microphone unavailable. Please grant microphone access in Settings.")
    }

    @Test func microphoneUnavailableIsError() {
        let error: Error = TunerError.microphoneUnavailable
        #expect(error.localizedDescription.isEmpty == false)
    }
}

// MARK: - PitchAccidentalDisplay

struct PitchAccidentalDisplayTests {

    @Test func allCasesPresent() {
        #expect(PitchAccidentalDisplay.allCases.count == 3)
    }

    @Test func rawValues() {
        #expect(PitchAccidentalDisplay.sharps.rawValue == "Sharps")
        #expect(PitchAccidentalDisplay.flats.rawValue == "Flats")
        #expect(PitchAccidentalDisplay.both.rawValue == "Sharps & Flats")
    }
}

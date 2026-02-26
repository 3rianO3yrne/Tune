//
//  TuneTests.swift
//  TuneTests
//
//  Created by Brian O'Byrne on 2/25/26.
//

import Testing
@testable import Tune

struct TuneTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

}

struct TunerEngineTests {

    // MARK: - Initial State

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

    // MARK: - Cents

    @Test func centsForPerfectA4IsZero() {
        let engine = TunerEngine()
        engine.update(frequency: 440.0)
        #expect(abs(engine.cents) < 0.01)
    }

    @Test func centsPositiveForSharpNote() {
        // A4 + 25 cents ≈ 446.37 Hz (440 × 2^(25/1200))
        let engine = TunerEngine()
        engine.update(frequency: 446.37)
        #expect(engine.cents > 20 && engine.cents < 30)
    }

    @Test func centsNegativeForFlatNote() {
        // A4 − 25 cents ≈ 433.93 Hz (440 / 2^(25/1200))
        let engine = TunerEngine()
        engine.update(frequency: 433.93)
        #expect(engine.cents < -20 && engine.cents > -30)
    }

    @Test func centsRangeClampedToHalfSemitone() {
        // A note exactly halfway between A4 and Bb4 should read ~50 cents
        // Bb4 = 466.16 Hz; midpoint ≈ 453.08 Hz
        let engine = TunerEngine()
        engine.update(frequency: 452.89)
        #expect(abs(engine.cents) <= 50)
    }

    // MARK: - Reference Pitch

    @Test func referencePitchAffectsCents() {
        let engine = TunerEngine()
        engine.referencePitch = 442.0
        engine.update(frequency: 440.0)
        // 440 Hz is flat relative to an A442 reference
        #expect(engine.cents < -5)
    }

    @Test func referencePitchDoesNotChangeNoteName() {
        let engine = TunerEngine()
        engine.referencePitch = 442.0
        engine.update(frequency: 440.0)
        // Still resolves to A4, just reads as flat
        #expect(engine.noteNameWithSharps == "A")
        #expect(engine.octave == 4)
    }

    @Test func referencePitch432CentsForA4() {
        let engine = TunerEngine()
        engine.referencePitch = 432.0
        engine.update(frequency: 432.0)
        #expect(abs(engine.cents) < 0.01)
    }
}

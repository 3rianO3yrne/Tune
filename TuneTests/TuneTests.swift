//
//  TuneTests.swift
//  TuneTests
//
//  Created by Brian O’Byrne on 2/25/26.
//

import Testing
@testable import Tune

struct TuneTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

}

struct TunerEngineTests {

    @Test func initialState() {
        let engine = TunerEngine()
        #expect(engine.frequency == 0)
        #expect(engine.noteNameWithSharps == "--")
        #expect(engine.noteNameWithFlats == "--")
        #expect(engine.octave == 0)
    }

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
}

//
//  ContentView.swift
//  Tune
//
//  Created by Brian O'Byrne on 2/25/26.
//

import SwiftUI

struct ContentView: View {
    @State private var tuner = TunerEngine()
    @State private var pitchAccidentalDisplay: PitchAccidentalDisplay = .sharps
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            Group {
                if let error = tuner.error {
                    ErrorView(error: error)
                } else {
                    TunerDialView(
                        cents: tuner.cents,
                        noteName: dialNoteName,
                        octave: tuner.octave
                    )
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .popover(isPresented: $showSettings) {
                        SettingsView(
                            pitchAccidentalDisplay: $pitchAccidentalDisplay,
                            referencePitch: Binding(
                                get: { tuner.referencePitch },
                                set: { tuner.referencePitch = $0 }
                            )
                        )
                    }
                }
            }
        }
        .task { tuner.start() }
        .onDisappear { tuner.stop() }
    }

    // MARK: - Computed Properties

    private var dialNoteName: String {
        guard tuner.frequency > 0 else { return "--" }
        switch pitchAccidentalDisplay {
        case .sharps:
            return tuner.noteNameWithSharps
        case .flats:
            return tuner.noteNameWithFlats
        case .both:
            let sharp = tuner.noteNameWithSharps
            let flat = tuner.noteNameWithFlats
            return sharp == flat ? sharp : "\(sharp)/\(flat)"
        }
    }
}

#Preview {
    ContentView()
}

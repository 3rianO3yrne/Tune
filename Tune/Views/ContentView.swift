//
//  ContentView.swift
//  Tune
//
//  Created by Brian O'Byrne on 2/25/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(TunerEngine.self) var tuner
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
                    .sheet(isPresented: $showSettings) {
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
        }
    }
}

#Preview {
    @Previewable @State var tuner = TunerEngine()
    ContentView()
        .environment(tuner)
}

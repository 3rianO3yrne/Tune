//
//  ContentView.swift
//  Tune
//
//  Created by Brian O'Byrne on 2/25/26.
//

import SwiftUI

enum PitchAccidentalDisplay: String, CaseIterable {
    case sharps = "Sharps"
    case flats = "Flats"
    case both = "Sharps & Flats"
}

struct ContentView: View {
    @State private var tuner = TunerEngine()
    @State private var pitchAccidentalDisplay: PitchAccidentalDisplay = .sharps

    var noteName: String {
        guard tuner.frequency > 0 else { return "--" }
        switch pitchAccidentalDisplay {
        case .sharps:
            return "\(tuner.noteNameWithSharps)\(tuner.octave)"
        case .flats:
            return "\(tuner.noteNameWithFlats)\(tuner.octave)"
        case .both:
            let sharp = tuner.noteNameWithSharps
            let flat = tuner.noteNameWithFlats
            return sharp == flat ? "\(sharp)\(tuner.octave)" : "\(sharp)/\(flat)\(tuner.octave)"
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text(noteName)
                    .font(.system(size: 80, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)

                Text(tuner.frequency > 0 ? String(format: "%.1f Hz", tuner.frequency) : "Listening...")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Display", selection: $pitchAccidentalDisplay) {
                            ForEach(PitchAccidentalDisplay.allCases, id: \.self) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
        .task {
            do {
                try tuner.start()
            } catch {
                print("Failed to start tuner: \(error)")
            }
        }
        .onDisappear {
            tuner.stop()
        }
    }
}

#Preview {
    ContentView()
}

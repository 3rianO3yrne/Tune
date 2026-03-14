//
//  SettingsView.swift
//  Tune
//
//  Created by Brian O'Byrne on 2/26/26.
//

import SwiftUI

struct SettingsView: View {
    @Binding var pitchAccidentalDisplay: PitchAccidentalDisplay
    @Binding var referencePitch: Float
    @Binding var colorSchemePreference: AppColorScheme
    @State private var showReferencePitch = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            Section("System") {
                Picker("Appearance", selection: $colorSchemePreference) {
                    ForEach(AppColorScheme.allCases, id: \.self) { option in
                        Text(option.label).tag(option)
                    }
                }
                .pickerStyle(.menu)
            }

            Section("Note Display") {
                Picker("Accidentals", selection: $pitchAccidentalDisplay) {
                    ForEach(PitchAccidentalDisplay.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.menu)
            }

            Section("Tuning") {
                Button {
                    showReferencePitch = true
                } label: {
                    LabeledContent("Reference Pitch") {
                        Text("A4 = \(Int(referencePitch)) Hz")
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                    }
                }
                .foregroundStyle(.primary)
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showReferencePitch) {
            ReferencePitchSheet(referencePitch: $referencePitch)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView(
            pitchAccidentalDisplay: .constant(.sharps),
            referencePitch: .constant(440.0),
            colorSchemePreference: .constant(.system)
        )
    }
}

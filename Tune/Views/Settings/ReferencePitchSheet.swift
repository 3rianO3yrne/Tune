//
//  ReferencePitchSheet.swift
//  Tune
//
//  Created by Brian O'Byrne on 2/26/26.
//

import SwiftUI

struct ReferencePitchSheet: View {
    @Binding var referencePitch: Float
    @Environment(\.dismiss) private var dismiss

    private static let pitchRange: [Float] = (420...450).map { Float($0) }
    private let defaultPitch: Float = 440.0

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Picker("Reference Pitch", selection: $referencePitch) {
                    ForEach(Self.pitchRange, id: \.self) { hz in
                        Text("\(Int(hz)) Hz").tag(hz)
                    }
                }
                .pickerStyle(.wheel)

                Button("Reset to 440 Hz") {
                    referencePitch = defaultPitch
                }
                .foregroundStyle(referencePitch == defaultPitch ? Color.secondary : Color.blue)
                .disabled(referencePitch == defaultPitch)
            }
            .padding()
            .navigationTitle("Reference Pitch")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    ReferencePitchSheet(referencePitch: .constant(440.0))
}

//
//  TunerView.swift
//  Tune
//
//  Created by Brian O'Byrne on 2/26/26.
//

import SwiftUI

struct TunerView: View {
    let frequency: Float
    let noteName: String
    let cents: Double
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Text(noteName)
                .font(.system(size: 96, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.4)
                .lineLimit(1)
                .contentTransition(.numericText())

            Text(frequency > 0 ? frequency.formattedFrequency : "Listening...")
                .font(.title2)
                .foregroundStyle(.secondary)
                .monospacedDigit()

            Spacer()

            if frequency > 0 {
                VStack(spacing: 8) {
                    CentsGauge(cents: cents)
                        .padding(.horizontal, 32)

                    HStack {
                        Text("−50")
                        Spacer()
                        Text(cents.formattedCentsLabel)
                            .monospacedDigit()
                            .fontWeight(.medium)
                            .foregroundStyle(cents.tuningAccuracyColor)
                        Spacer()
                        Text("+50")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 32)
                }
                .transition(.opacity)
            }

            Spacer()
        }
        .padding()
        .animation(.easeInOut(duration: 0.2), value: frequency > 0)
    }
}

#Preview("Active Tuning") {
    TunerView(
        frequency: 440.0,
        noteName: "A4",
        cents: 12.5
    )
}

#Preview("Listening") {
    TunerView(
        frequency: 0,
        noteName: "--",
        cents: 0
    )
}

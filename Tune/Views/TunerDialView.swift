//
//  TunerDialView.swift
//  Tune
//
import SwiftUI

// MARK: - Main Tuner Shell

struct TunerDialView: View {
    @Environment(\.colorScheme) var colorScheme

    var cents: Double = 0
    var noteName: String = "--"
    var octave: Int = 4

    private func gaugeSize(for geo: GeometryProxy) -> CGSize {
        let isLandscape = geo.size.width > geo.size.height
        let availW = geo.size.width  * 0.88
        let availH = geo.size.height * (isLandscape ? 0.80 : 0.62)
        if availW / availH > 2.0 {
            return CGSize(width: availH * 2.0, height: availH)
        } else {
            return CGSize(width: availW, height: availW / 2.0)
        }
    }

    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height
            let gauge = gaugeSize(for: geo)
            let gaugeW = gauge.width
            let gaugeH = gauge.height

            ZStack {
                // Metal base
                BrushedMetalBackground()
                    .ignoresSafeArea()

                VStack(spacing: isLandscape ? 16 : 20) {
                    Spacer()

                    // Oval gauge
                    OvalBezelView(cents: cents, size: CGSize(width: gaugeW, height: gaugeH))
                        // Smooths out the needle animation
                        .animation(.spring(response: 0.25, dampingFraction: 0.75), value: cents)
                        .environment(\.hasSignal, noteName != "--")

                    // Bottom row — note readout left
                    HStack {
                        NoteReadoutPanel(noteName: noteName, octave: octave)
                        Spacer()
                    }
                    .padding(.horizontal, 28)
                    .frame(width: gaugeW + 20)

                    Spacer()
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Light — In Tune") {
    TunerDialView(cents: 0, noteName: "A", octave: 4)
        .preferredColorScheme(.light)
}

#Preview("Light — Sharp") {
    TunerDialView(cents: 22, noteName: "C", octave: 5)
        .preferredColorScheme(.light)
}

#Preview("Dark — Flat") {
    TunerDialView(cents: -35, noteName: "G", octave: 3)
        .preferredColorScheme(.dark)
}

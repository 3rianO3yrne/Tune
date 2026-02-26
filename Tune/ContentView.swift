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
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            Group {
                if let error = tuner.error {
                    errorView(error)
                } else {
                    tunerView
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
                        SettingsPopover(
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
        .task {
            tuner.start()
        }
        .onDisappear {
            tuner.stop()
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var tunerView: some View {
        VStack(spacing: 16) {
            Spacer()

            Text(noteName)
                .font(.system(size: 96, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.4)
                .lineLimit(1)
                .contentTransition(.numericText())

            Text(tuner.frequency > 0 ? String(format: "%.1f Hz", tuner.frequency) : "Listening...")
                .font(.title2)
                .foregroundStyle(.secondary)
                .monospacedDigit()

            Spacer()

            if tuner.frequency > 0 {
                VStack(spacing: 8) {
                    CentsGauge(cents: tuner.cents)
                        .padding(.horizontal, 32)

                    HStack {
                        Text("−50")
                        Spacer()
                        Text(centsLabel)
                            .monospacedDigit()
                            .fontWeight(.medium)
                            .foregroundStyle(centsColor)
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
        .animation(.easeInOut(duration: 0.2), value: tuner.frequency > 0)
    }

    @ViewBuilder
    private func errorView(_ error: Error) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "mic.slash.fill")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)
            Text(error.localizedDescription)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Computed Properties

    private var noteName: String {
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

    private var centsLabel: String {
        let c = tuner.cents
        if abs(c) < 0.5 { return "in tune" }
        return c > 0 ? String(format: "+%.0f¢", c) : String(format: "%.0f¢", c)
    }

    private var centsColor: Color {
        switch abs(tuner.cents) {
        case ..<5:  return .green
        case ..<20: return .yellow
        default:    return .red
        }
    }
}

// MARK: - SettingsPopover

private struct SettingsPopover: View {
    @Binding var pitchAccidentalDisplay: PitchAccidentalDisplay
    @Binding var referencePitch: Float
    @State private var showReferencePitch = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {

        List {
            Section("Display") {
                Picker("Accidentals", selection: $pitchAccidentalDisplay) {
                    ForEach(PitchAccidentalDisplay.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
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
        .presentationCompactAdaptation(.sheet)
        .sheet(isPresented: $showReferencePitch) {
            ReferencePitchSheet(referencePitch: $referencePitch)
        }

    }
}

// MARK: - ReferencePitchSheet

private struct ReferencePitchSheet: View {
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

// MARK: - CentsGauge

private struct CentsGauge: View {
    let cents: Double

    private var clamped: Double { min(max(cents, -50), 50) }

    private var needleColor: Color {
        switch abs(clamped) {
        case ..<5:  return .green
        case ..<20: return .yellow
        default:    return .red
        }
    }

    var body: some View {
        GeometryReader { geo in
            let needleDiameter: CGFloat = 22
            let midY = geo.size.height / 2
            let travel = geo.size.width - needleDiameter
            let needleX = needleDiameter / 2 + CGFloat((clamped + 50) / 100) * travel

            ZStack {
                // Track
                Capsule()
                    .fill(Color.secondary.opacity(0.15))
                    .frame(width: geo.size.width, height: 6)
                    .position(x: geo.size.width / 2, y: midY)

                // In-tune zone
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.green.opacity(0.2))
                    .frame(width: travel * 0.1 + needleDiameter, height: 6)
                    .position(x: geo.size.width / 2, y: midY)

                // Center tick
                Rectangle()
                    .fill(Color.secondary.opacity(0.5))
                    .frame(width: 2, height: 14)
                    .position(x: geo.size.width / 2, y: midY)

                // Needle
                Circle()
                    .fill(needleColor)
                    .shadow(color: needleColor.opacity(0.3), radius: 3, x: 0, y: 1)
                    .frame(width: needleDiameter, height: needleDiameter)
                    .position(x: needleX, y: midY)
            }
        }
        .frame(height: 22)
        .animation(.interpolatingSpring(stiffness: 200, damping: 20), value: cents)
    }
}

#Preview {
    ContentView()
}

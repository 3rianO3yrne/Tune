//
//  NoteReadoutPanel.swift
//  Tune
//
import SwiftUI

struct NoteReadoutPanel: View {
    @Environment(\.colorScheme) var colorScheme

    var noteName: String
    var octave: Int

    var faceColor: Color {
        colorScheme == .dark ? .readoutFaceDark : .readoutFaceLight
    }

    var body: some View {
        ZStack {
            // Panel shadow
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.black.opacity(0.4))
                .blur(radius: 4)
                .offset(y: 3)

            // Bezel
            RoundedRectangle(cornerRadius: 6)
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color.bezelHighlight, location: 0.0),
                            .init(color: Color.gunmetalDark,   location: 1.0),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding(-3)

            // Face
            RoundedRectangle(cornerRadius: 5)
                .fill(faceColor)

            // Glass sheen
            RoundedRectangle(cornerRadius: 5)
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color.white.opacity(0.15), location: 0.0),
                            .init(color: Color.clear,               location: 0.6),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            // Note text
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(noteName)
                    .font(.system(size: 28, weight: .semibold, design: .serif))
                    .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.85) : Color.black.opacity(0.75))

                if noteName != "--" {
                    Text("\(octave)")
                        .font(.system(size: 16, weight: .regular, design: .serif))
                        .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.55) : Color.black.opacity(0.45))
                        .offset(y: -4)
                }
            }
        }
        .frame(width: 80, height: 52)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

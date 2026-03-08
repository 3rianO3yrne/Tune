//
//  OvalBezelView.swift
//  Tune
//
import SwiftUI

struct OvalBezelView: View {
    @Environment(\.colorScheme) var colorScheme

    let cents: Double
    let size: CGSize

    var body: some View {
        let w = size.width
        let h = size.height

        ZStack {
            // Outer shadow ring (depth below bezel)
            Ellipse()
                .fill(Color.bezelShadow)
                .frame(width: w + 12, height: h + 12)
                .blur(radius: 6)
                .offset(y: 4)

            // Bezel body
            Ellipse()
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color.bezelHighlight, location: 0.0),
                            .init(color: Color.gunmetalLight,  location: 0.25),
                            .init(color: Color.gunmetalDark,   location: 0.6),
                            .init(color: Color.bezelHighlight.opacity(0.4), location: 1.0),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: w + 20, height: h + 20)

            // Inner shadow on bezel (sells the recess)
            Ellipse()
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.6),
                            Color.white.opacity(0.1),
                            Color.black.opacity(0.4),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .frame(width: w + 20, height: h + 20)

            // Gauge face
            GaugeFaceView(cents: cents, size: size)
                .frame(width: w, height: h)
        }
    }
}

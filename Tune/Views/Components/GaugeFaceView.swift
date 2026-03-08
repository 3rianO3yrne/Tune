//
//  GaugeFaceView.swift
//  Tune
//
import SwiftUI

struct GaugeFaceView: View {
    @Environment(\.colorScheme) var colorScheme

    let cents: Double
    let size: CGSize

    var faceColor: Color {
        colorScheme == .dark ? .gaugeFaceDark : .gaugeFaceLight
    }

    var body: some View {
        let w = size.width
        let h = size.height

        ZStack {
            // Base face color
            Ellipse()
                .fill(faceColor)

            // Subtle inner gradient — slightly brighter at top center
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(colorScheme == .dark ? 0.05 : 0.20),
                            Color.clear,
                        ],
                        center: UnitPoint(x: 0.5, y: 0.25),
                        startRadius: 0,
                        endRadius: w * 0.6
                    )
                )

            // Arc gauge
            ArcGauge(cents: cents)
                .frame(width: w, height: h)

            // Glass sheen — convex highlight band across upper portion
            Ellipse()
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color.white.opacity(0.18), location: 0.0),
                            .init(color: Color.white.opacity(0.06), location: 0.4),
                            .init(color: Color.clear,               location: 0.7),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .scaleEffect(x: 0.85, y: 0.45)
                .offset(y: -h * 0.22)
                .blur(radius: 2)
                .clipShape(Ellipse())

            // Edge darkening — sells the glass curvature
            Ellipse()
                .strokeBorder(
                    RadialGradient(
                        colors: [Color.clear, Color.black.opacity(0.25)],
                        center: .center,
                        startRadius: w * 0.3,
                        endRadius: w * 0.55
                    ),
                    lineWidth: 18
                )
        }
        .frame(width: w, height: h)
        .clipShape(Ellipse())
    }
}

#Preview("Light — In Tune") {
    GaugeFaceView(cents: 0, size: CGSize(width: 300, height: 150))
        .preferredColorScheme(.light)
        .padding()
        .environment(\.hasSignal, true)
}

#Preview("Dark — Sharp") {
    GaugeFaceView(cents: 28, size: CGSize(width: 300, height: 150))
        .preferredColorScheme(.dark)
        .padding()
        .background(Color.black)
        .environment(\.hasSignal, true)
}

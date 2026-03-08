//
//  BrushedMetalBackground.swift
//  Tune
//
import SwiftUI

/// Brushed metal gradient simulating machined gunmetal
struct BrushedMetalBackground: View {
    var body: some View {
        ZStack {
            // Base gunmetal
            Color.gunmetal

            // Subtle horizontal brush strokes via repeating gradient bands
            LinearGradient(
                stops: [
                    .init(color: Color.white.opacity(0.00), location: 0.00),
                    .init(color: Color.white.opacity(0.03), location: 0.15),
                    .init(color: Color.white.opacity(0.00), location: 0.30),
                    .init(color: Color.white.opacity(0.04), location: 0.45),
                    .init(color: Color.white.opacity(0.01), location: 0.60),
                    .init(color: Color.white.opacity(0.05), location: 0.75),
                    .init(color: Color.white.opacity(0.00), location: 1.00),
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // Vignette — darker toward edges
            RadialGradient(
                colors: [Color.clear, Color.black.opacity(0.35)],
                center: .center,
                startRadius: 0,
                endRadius: 500
            )
        }
    }
}

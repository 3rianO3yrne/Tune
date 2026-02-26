//
//  CentsGauge.swift
//  Tune
//
//  Created by Brian O'Byrne on 2/26/26.
//

import SwiftUI

struct CentsGauge: View {
    let cents: Double

    private var clamped: Double { min(max(cents, -50), 50) }

    private var needleColor: Color {
        clamped.tuningAccuracyColor
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
    VStack(spacing: 20) {
        CentsGauge(cents: 0)
        CentsGauge(cents: -25)
        CentsGauge(cents: 15)
    }
    .padding()
}

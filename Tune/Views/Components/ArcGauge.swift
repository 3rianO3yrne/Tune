//
//  ArcGauge.swift
//  Tune
//
//  Created by Brian O'Byrne on 3/7/26.
//

import SwiftUI

struct ArcGauge: View, Animatable {
    var cents: Double   // var required for Animatable

    var animatableData: Double {
        get { cents }
        set { cents = newValue }
    }

    private var clamped: Double { min(max(cents, -50), 50) }

    private var needleAngleDeg: Double {
        let t = (clamped + 50) / 100
        return 180 + t * 180
    }

    private var needleColor: Color { clamped.tuningAccuracyColor }

    var body: some View {
        let angleDeg = needleAngleDeg
        let nColor = needleColor

        Canvas { ctx, size in
            let pivot = CGPoint(x: size.width / 2, y: size.height)
            let radius: CGFloat = min(size.width / 2, size.height - 4) * 0.88
            let trackW: CGFloat = 7
            let needleR = radius - trackW / 2
            let nRad = Angle.degrees(angleDeg).radians

            // Background arc track
            var track = Path()
            track.addArc(center: pivot, radius: radius,
                         startAngle: .degrees(180), endAngle: .degrees(0), clockwise: true)
            ctx.stroke(track, with: .color(.secondary.opacity(0.15)),
                       style: StrokeStyle(lineWidth: trackW, lineCap: .round))

            // In-tune zone (±5¢ = ±9°)
            var zone = Path()
            zone.addArc(center: pivot, radius: radius,
                        startAngle: .degrees(261), endAngle: .degrees(279), clockwise: true)
            ctx.stroke(zone, with: .color(.green.opacity(0.3)),
                       style: StrokeStyle(lineWidth: trackW + 6, lineCap: .round))

            // Tick marks at -50, -25, 0, +25, +50
            for t in [-50.0, -25.0, 0.0, 25.0, 50.0] {
                let a = Angle.degrees(180 + (t + 50) / 100 * 180).radians
                var tick = Path()
                tick.move(to: CGPoint(x: pivot.x + CGFloat(cos(a)) * (radius - 10),
                                      y: pivot.y + CGFloat(sin(a)) * (radius - 10)))
                tick.addLine(to: CGPoint(x: pivot.x + CGFloat(cos(a)) * (radius + 4),
                                         y: pivot.y + CGFloat(sin(a)) * (radius + 4)))
                ctx.stroke(tick, with: .color(.secondary.opacity(0.4)),
                           style: StrokeStyle(lineWidth: t == 0 ? 2 : 1))
            }

            // Needle
            var needle = Path()
            needle.move(to: pivot)
            needle.addLine(to: CGPoint(x: pivot.x + CGFloat(cos(nRad)) * needleR,
                                       y: pivot.y + CGFloat(sin(nRad)) * needleR))
            ctx.stroke(needle, with: .color(nColor),
                       style: StrokeStyle(lineWidth: 2, lineCap: .round))

            // Needle tip
            let tipR: CGFloat = 5
            let tipCenter = CGPoint(x: pivot.x + CGFloat(cos(nRad)) * needleR,
                                    y: pivot.y + CGFloat(sin(nRad)) * needleR)
            ctx.fill(Path(ellipseIn: CGRect(x: tipCenter.x - tipR, y: tipCenter.y - tipR,
                                            width: tipR * 2, height: tipR * 2)),
                     with: .color(nColor))

            // Pivot
            let pivotR: CGFloat = 5
            ctx.fill(Path(ellipseIn: CGRect(x: pivot.x - pivotR, y: pivot.y - pivotR,
                                            width: pivotR * 2, height: pivotR * 2)),
                     with: .color(.secondary.opacity(0.4)))
        }
        .frame(height: 150)
    }
}

#Preview {
    VStack(spacing: 40) {
        ArcGauge(cents: 0)
        ArcGauge(cents: -25)
        ArcGauge(cents: 15)
    }
    .padding()
}

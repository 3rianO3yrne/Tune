//
//  ArcGauge.swift
//  Tune
//
//  Created by Brian O'Byrne on 3/7/26.
//

import SwiftUI

struct ArcGauge: View, Animatable {
    var cents: Double  // var required for Animatable

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.hasSignal) var hasSignal

    var animatableData: Double {
        get { cents }
        set { cents = newValue }
    }

    private var clamped: Double { min(max(cents, -50), 50) }

    private var needleAngleDeg: Double {
        Self.arcAngleDeg(for: clamped)
    }

    private var needleColor: Color { clamped.tuningAccuracyColor }

    private static func arcAngleDeg(for cents: Double) -> Double {
        200 + (cents + 50) / 100 * 140
    }

    private static func drawPivotDot(
        in ctx: inout GraphicsContext,
        at pivot: CGPoint,
        radius pivotR: CGFloat,
        color: Color
    ) {
        ctx.fill(
            Path(ellipseIn: CGRect(x: pivot.x - pivotR, y: pivot.y - pivotR,
                                   width: pivotR * 2, height: pivotR * 2)),
            with: .color(color.opacity(0.15))
        )
        ctx.fill(
            Path(ellipseIn: CGRect(x: pivot.x - pivotR * 0.55, y: pivot.y - pivotR * 0.55,
                                   width: pivotR * 1.1, height: pivotR * 1.1)),
            with: .color(color.opacity(0.9))
        )
    }

    var body: some View {
        let isDark = colorScheme == .dark
        let angleDeg = needleAngleDeg
        let nColor = needleColor
        let clampedVal = clamped
        let signal = hasSignal

        Canvas { ctx, size in
            let pivot = CGPoint(x: size.width / 2, y: size.height * 0.93)
            let radius: CGFloat = min(size.width / 2, size.height * 0.93) * 0.88
            let trackW: CGFloat = max(12, size.height * 0.15)
            let needleR = radius
            let nRad = Angle.degrees(angleDeg).radians
            let tRad = Angle.degrees(angleDeg + 180).radians
            let pivotR = size.height * 0.93 * 0.065 / 2

            // Arc band — drawn before ticks so ticks render on top
            let arcRadius: CGFloat = radius + trackW * 0.0
            var arc = Path()
            arc.addArc(
                center: pivot,
                radius: arcRadius,
                startAngle: .degrees(0),
                endAngle: .degrees(180),
                clockwise: true
            )

            if signal {
                // Outer glow
                ctx.stroke(
                    arc,
                    with: .color(clampedVal.tuningAccuracyColor.opacity(0.08)),
                    style: StrokeStyle(lineWidth: trackW * 1.85, lineCap: .butt)
                )
                // Mid glow
                ctx.stroke(
                    arc,
                    with: .color(clampedVal.tuningAccuracyColor.opacity(0.10)),
                    style: StrokeStyle(lineWidth: trackW * 1.45, lineCap: .butt)
                )
                // Main arc
                ctx.stroke(
                    arc,
                    with: .color(clampedVal.tuningAccuracyColor.opacity(0.50)),
                    style: StrokeStyle(lineWidth: trackW, lineCap: .butt)
                )

            } else {
                // Grayed out (no signal)
                ctx.stroke(
                    arc,
                    with: .color(Color.gray.opacity(0.18)),
                    style: StrokeStyle(lineWidth: trackW, lineCap: .butt)
                )
            }

            // Tick marks every 10¢ (-50 to +50)
            for t in stride(from: -50.0, through: 50.0, by: 10.0) {
                let a = Angle.degrees(Self.arcAngleDeg(for: t)).radians
                let isCenter = t == 0
                let inner = radius - trackW * (isCenter ? 1.0 : 0.8)
                let outer = radius + trackW * (isCenter ? 1.0 : 0.8)
                var tick = Path()
                tick.move(
                    to: CGPoint(
                        x: pivot.x + CGFloat(cos(a)) * inner,
                        y: pivot.y + CGFloat(sin(a)) * inner
                    )
                )
                tick.addLine(
                    to: CGPoint(
                        x: pivot.x + CGFloat(cos(a)) * outer,
                        y: pivot.y + CGFloat(sin(a)) * outer
                    )
                )
                let op = isCenter ? (isDark ? 0.7 : 0.6) : (isDark ? 0.4 : 0.3)
                let tickColor: Color = isDark ? .white.opacity(op) : .black.opacity(op)
                ctx.stroke(
                    tick,
                    with: .color(tickColor),
                    style: StrokeStyle(lineWidth: isCenter ? 2 : 1)
                )
            }

            // Needle with short tail — neon glow via layered strokes (wide→dim to narrow→bright)
            let tailLen = size.height * 0.93 * 0.07
            var needle = Path()
            needle.move(
                to: CGPoint(
                    x: pivot.x + CGFloat(cos(tRad)) * tailLen,
                    y: pivot.y + CGFloat(sin(tRad)) * tailLen
                )
            )
            needle.addLine(
                to: CGPoint(
                    x: pivot.x + CGFloat(cos(nRad)) * needleR,
                    y: pivot.y + CGFloat(sin(nRad)) * needleR
                )
            )

            if signal {
                // Glowing needle
                ctx.stroke(needle, with: .color(nColor.opacity(0.08)),
                           style: StrokeStyle(lineWidth: 15, lineCap: .round))
                ctx.stroke(needle, with: .color(nColor.opacity(0.22)),
                           style: StrokeStyle(lineWidth: 7, lineCap: .round))
                ctx.stroke(needle, with: .color(nColor.opacity(0.95)),
                           style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                // Sharp edge — simulates the lit surface of a plastic tube
                ctx.stroke(needle, with: .color(Color.white.opacity(0.95)),
                           style: StrokeStyle(lineWidth: 0.75, lineCap: .round))

                Self.drawPivotDot(in: &ctx, at: pivot, radius: pivotR, color: nColor)
            } else {
                // Grayed out (no signal)
                ctx.stroke(needle, with: .color(Color.noSignalNeedle.opacity(0.95)),
                           style: StrokeStyle(lineWidth: 2.5, lineCap: .round))

                Self.drawPivotDot(in: &ctx, at: pivot, radius: pivotR, color: .noSignalNeedle)
            }
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        ArcGauge(cents: 0)
            .frame(width: 300, height: 150)
            .environment(\.hasSignal, true)
        ArcGauge(cents: 10)
            .frame(width: 300, height: 150)
            .environment(\.hasSignal, true)
        ArcGauge(cents: -23)
            .frame(width: 300, height: 150)
            .environment(\.hasSignal, true)
        ArcGauge(cents: -45)
            .frame(width: 300, height: 150)
            .environment(\.hasSignal, true)
        ArcGauge(cents: 0)
            .frame(width: 300, height: 150)
            .environment(\.hasSignal, false)
    }
    .padding()
    .preferredColorScheme(.dark)
}

#Preview {
    VStack(spacing: 24) {
        ArcGauge(cents: 0)
            .frame(width: 300, height: 150)
            .environment(\.hasSignal, true)
        ArcGauge(cents: 10)
            .frame(width: 300, height: 150)
            .environment(\.hasSignal, true)
        ArcGauge(cents: -23)
            .frame(width: 300, height: 150)
            .environment(\.hasSignal, true)
        ArcGauge(cents: -45)
            .frame(width: 300, height: 150)
            .environment(\.hasSignal, true)
        ArcGauge(cents: 0)
            .frame(width: 300, height: 150)
            .environment(\.hasSignal, false)
    }
    .padding()
    .preferredColorScheme(.light)
}

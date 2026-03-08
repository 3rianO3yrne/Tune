//
//  ArcGauge.swift
//  Tune
//
//  Created by Brian O'Byrne on 3/7/26.
//

import SwiftUI

struct ArcGauge: View, Animatable {
    var cents: Double   // var required for Animatable

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.hasSignal) var hasSignal

    var animatableData: Double {
        get { cents }
        set { cents = newValue }
    }

    private var clamped: Double { min(max(cents, -50), 50) }

    private var needleAngleDeg: Double {
        200 + (clamped + 50) / 100 * 140
    }

    private var needleColor: Color { clamped.tuningAccuracyColor }
    private var segmentColor: Color { abs(clamped) <= 10 ? .green : .red }

    var body: some View {
        let isDark = colorScheme == .dark
        let angleDeg = needleAngleDeg
        let nColor = needleColor
        let clampedCents = clamped

        Canvas { ctx, size in
            let pivot = CGPoint(x: size.width / 2, y: size.height * 0.93)
            let radius: CGFloat = min(size.width / 2, size.height * 0.93) * 0.88
            let trackW: CGFloat = max(12, size.height * 0.15)
            let needleR = radius - trackW / 2
            let nRad = Angle.degrees(angleDeg).radians
            let tRad = Angle.degrees(angleDeg + 180).radians
            let gap: Double = 1.0

            // Active segment index (0–9)
            let activeIndex = min(Int((clampedCents + 50) / 10), 9)

            // Segments — one per 10¢ interval across the 140° sweep
            for i in 0..<10 {
                let c1 = Double(i) * 10 - 50
                let c2 = c1 + 10
                let a1 = 200 + (c1 + 50) / 100 * 140 + gap
                let a2 = 200 + (c2 + 50) / 100 * 140 - gap

                var seg = Path()
                seg.addArc(center: pivot, radius: radius,
                           startAngle: .degrees(a1), endAngle: .degrees(a2), clockwise: true)

                let inTuneRange = abs(clampedCents) <= 10
                let isInner = i == 4 || i == 5
                let isActive = hasSignal && (i == activeIndex || (inTuneRange && isInner))
                let dimColor: Color = isDark ? .white.opacity(0.12) : .black.opacity(0.10)
                let mutedColor: Color = isDark ? .white.opacity(0.04) : .black.opacity(0.04)
                let color: Color = isActive ? segmentColor.opacity(0.85)
                    : (inTuneRange && !isInner ? mutedColor : dimColor)

                ctx.stroke(seg, with: .color(color),
                           style: StrokeStyle(lineWidth: trackW, lineCap: .butt))
            }

            // Tick marks every 10¢ (-50 to +50)
            for t in stride(from: -50.0, through: 50.0, by: 10.0) {
                let a = Angle.degrees(200 + (t + 50) / 100 * 140).radians
                let isCenter = t == 0
                let inner = radius - trackW * (isCenter ? 1.4 : 1.1)
                let outer = radius + trackW * (isCenter ? 1.0 : 0.8)
                var tick = Path()
                tick.move(to: CGPoint(x: pivot.x + CGFloat(cos(a)) * inner,
                                      y: pivot.y + CGFloat(sin(a)) * inner))
                tick.addLine(to: CGPoint(x: pivot.x + CGFloat(cos(a)) * outer,
                                         y: pivot.y + CGFloat(sin(a)) * outer))
                let op = isCenter ? (isDark ? 0.7 : 0.6) : (isDark ? 0.4 : 0.3)
                let tickColor: Color = isDark ? .white.opacity(op) : .black.opacity(op)
                ctx.stroke(tick, with: .color(tickColor),
                           style: StrokeStyle(lineWidth: isCenter ? 2 : 1))
            }

            // Needle with short tail — neon glow via layered strokes (wide→dim to narrow→bright)
            let tailLen = size.height * 0.93 * 0.07
            var needle = Path()
            needle.move(to: CGPoint(x: pivot.x + CGFloat(cos(tRad)) * tailLen,
                                    y: pivot.y + CGFloat(sin(tRad)) * tailLen))
            needle.addLine(to: CGPoint(x: pivot.x + CGFloat(cos(nRad)) * needleR,
                                       y: pivot.y + CGFloat(sin(nRad)) * needleR))
            // Outer glow
            ctx.stroke(needle, with: .color(nColor.opacity(0.08)),
                       style: StrokeStyle(lineWidth: 8, lineCap: .round))
            // Mid glow
            ctx.stroke(needle, with: .color(nColor.opacity(0.22)),
                       style: StrokeStyle(lineWidth: 4, lineCap: .round))
            // Bright core
            ctx.stroke(needle, with: .color(nColor.opacity(0.95)),
                       style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
            // Sharp specular edge — simulates the lit surface of a plastic tube
            ctx.stroke(needle, with: .color(Color.white.opacity(0.75)),
                       style: StrokeStyle(lineWidth: 0.75, lineCap: .round))

            // Pivot dot — glowing to match needle
            let pivotR = size.height * 0.93 * 0.065 / 2
            ctx.fill(Path(ellipseIn: CGRect(x: pivot.x - pivotR, y: pivot.y - pivotR,
                                            width: pivotR * 2, height: pivotR * 2)),
                     with: .color(nColor.opacity(0.15)))
            ctx.fill(Path(ellipseIn: CGRect(x: pivot.x - pivotR * 0.55, y: pivot.y - pivotR * 0.55,
                                            width: pivotR * 1.1, height: pivotR * 1.1)),
                     with: .color(nColor.opacity(0.9)))
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        ArcGauge(cents: 0)
            .frame(width: 300, height: 150)
        ArcGauge(cents: -10)
            .frame(width: 300, height: 150)
        ArcGauge(cents: 15)
            .frame(width: 300, height: 150)
        ArcGauge(cents: -48)
            .frame(width: 300, height: 150)
    }
    .padding()
    .environment(\.hasSignal, true)
}

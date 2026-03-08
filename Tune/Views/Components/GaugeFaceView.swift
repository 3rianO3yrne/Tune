//
//  GaugeFaceView.swift
//  Tune
//
import SwiftUI

// MARK: - Arc Gauge Needle

struct GaugeArcContent: View, Animatable {
    @Environment(\.colorScheme) var colorScheme

    var cents: Double   // var required for Animatable
    let size: CGSize

    var animatableData: Double {
        get { cents }
        set { cents = newValue }
    }

    private var clamped: Double { min(max(cents, -50), 50) }
    private var needleAngleDeg: Double { 200 + (clamped + 50) / 100 * 140 }
    private var needleColor: Color { clamped.tuningAccuracyColor }

    var body: some View {
        let isDark = colorScheme == .dark
        let w = size.width
        let h = size.height
        let angleDeg = needleAngleDeg
        let nColor = needleColor

        Canvas { ctx, _ in
            let pivot = CGPoint(x: w / 2, y: h * 0.93)
            let radius: CGFloat = h * 0.70
            let trackW: CGFloat = max(4, h * 0.045)
            let nRad = Angle.degrees(angleDeg).radians
            let tRad = Angle.degrees(angleDeg + 180).radians

            // Background arc track
            var track = Path()
            track.addArc(center: pivot, radius: radius,
                         startAngle: .degrees(200), endAngle: .degrees(340), clockwise: true)
            let trackColor: Color = isDark ? .white.opacity(0.12) : .black.opacity(0.10)
            ctx.stroke(track, with: .color(trackColor),
                       style: StrokeStyle(lineWidth: trackW, lineCap: .round))

            // In-tune zone (±5¢ → ±7° of 140° sweep)
            var zone = Path()
            zone.addArc(center: pivot, radius: radius,
                        startAngle: .degrees(263), endAngle: .degrees(277), clockwise: true)
            ctx.stroke(zone, with: .color(.green.opacity(0.45)),
                       style: StrokeStyle(lineWidth: trackW + h * 0.02, lineCap: .round))

            // Tick marks at -50, -25, 0, +25, +50
            for t in [-50.0, -25.0, 0.0, 25.0, 50.0] {
                let a = Angle.degrees(200 + (t + 50) / 100 * 140).radians
                let inner = radius - trackW * 1.1
                let outer = radius + trackW * 0.8
                var tick = Path()
                tick.move(to: CGPoint(x: pivot.x + CGFloat(cos(a)) * inner,
                                      y: pivot.y + CGFloat(sin(a)) * inner))
                tick.addLine(to: CGPoint(x: pivot.x + CGFloat(cos(a)) * outer,
                                         y: pivot.y + CGFloat(sin(a)) * outer))
                let op = t == 0 ? (isDark ? 0.7 : 0.6) : (isDark ? 0.4 : 0.3)
                let tickColor: Color = isDark ? .white.opacity(op) : .black.opacity(op)
                ctx.stroke(tick, with: .color(tickColor),
                           style: StrokeStyle(lineWidth: t == 0 ? 2 : 1))
            }

            // Needle with short tail
            let tipR = radius - trackW * 0.5
            let tailR = h * 0.07
            var needle = Path()
            needle.move(to: CGPoint(x: pivot.x + CGFloat(cos(tRad)) * tailR,
                                    y: pivot.y + CGFloat(sin(tRad)) * tailR))
            needle.addLine(to: CGPoint(x: pivot.x + CGFloat(cos(nRad)) * tipR,
                                       y: pivot.y + CGFloat(sin(nRad)) * tipR))
            ctx.stroke(needle, with: .color(nColor),
                       style: StrokeStyle(lineWidth: 1.5, lineCap: .round))

            // Pivot dot
            let dotR = h * 0.065 / 2
            let pivotColor: Color = isDark ? .white.opacity(0.45) : .black.opacity(0.35)
            let pivotRect = CGRect(x: pivot.x - dotR, y: pivot.y - dotR,
                                   width: dotR * 2, height: dotR * 2)
            ctx.fill(Path(ellipseIn: pivotRect), with: .color(pivotColor))
        }
        .frame(width: w, height: h)
    }
}

// MARK: - Gauge Face (glass oval)

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

            // Arc gauge needle
            GaugeArcContent(cents: cents, size: size)

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
}

#Preview("Dark — Sharp") {
    GaugeFaceView(cents: 28, size: CGSize(width: 300, height: 150))
        .preferredColorScheme(.dark)
        .padding()
        .background(Color.black)
}

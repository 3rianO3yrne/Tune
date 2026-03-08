//
//  TunerDialView.swift
//  Tune
//
//  Created by Brian O’Byrne on 3/7/26.
//
import SwiftUI

// MARK: - Design Tokens
extension Color {
    // Metal base
    static let gunmetal          = Color(hex: "#2C3035")
    static let gunmetalDark      = Color(hex: "#1A1D20")
    static let gunmetalLight     = Color(hex: "#3D4349")
    static let bezelHighlight    = Color(hex: "#8A9099")
    static let bezelShadow       = Color(hex: "#111315")

    // Gauge face
    static let gaugeFaceLight    = Color(hex: "#F2EDE4")
    static let gaugeFaceDark     = Color(hex: "#1C1A18")

    // Readout panel
    static let readoutFaceLight  = Color(hex: "#EDE8DF")
    static let readoutFaceDark   = Color(hex: "#161412")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double(int         & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Metal Texture Helpers

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

// MARK: - Oval Bezel Shape

struct OvalBezelView: View {
    @Environment(\.colorScheme) var colorScheme

    let cents: Double
    let size: CGSize

    var body: some View {
        let w = size.width
        let h = size.height

        ZStack {
            // --- Outer shadow ring (depth below bezel) ---
            Ellipse()
                .fill(Color.bezelShadow)
                .frame(width: w + 12, height: h + 12)
                .blur(radius: 6)
                .offset(y: 4)

            // --- Bezel body ---
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

            // --- Inner shadow on bezel (sells the recess) ---
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

            // --- Gauge face ---
            GaugeFaceView(cents: cents, size: size)
                .frame(width: w, height: h)
        }
    }
}

// MARK: - Arc Gauge Needle (inside oval face)

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

// MARK: - Note Readout Panel

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

// MARK: - Main Tuner Shell

struct TunerDialView: View {
    @Environment(\.colorScheme) var colorScheme

    var cents: Double = 0
    var noteName: String = "--"
    var octave: Int = 4

    private func gaugeSize(for geo: GeometryProxy) -> CGSize {
        let isLandscape = geo.size.width > geo.size.height
        let availW = geo.size.width  * 0.88
        let availH = geo.size.height * (isLandscape ? 0.80 : 0.62)
        if availW / availH > 2.0 {
            return CGSize(width: availH * 2.0, height: availH)
        } else {
            return CGSize(width: availW, height: availW / 2.0)
        }
    }

    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height
            let gauge = gaugeSize(for: geo)
            let gaugeW = gauge.width
            let gaugeH = gauge.height

            ZStack {
                // Metal base
                BrushedMetalBackground()
                    .ignoresSafeArea()

                VStack(spacing: isLandscape ? 16 : 20) {
                    Spacer()

                    // Oval gauge
                    OvalBezelView(cents: cents, size: CGSize(width: gaugeW, height: gaugeH))
                        .animation(.spring(response: 0.25, dampingFraction: 0.75), value: cents)

                    // Bottom row — note readout left
                    HStack {
                        NoteReadoutPanel(noteName: noteName, octave: octave)
                        Spacer()
                    }
                    .padding(.horizontal, 28)
                    .frame(width: gaugeW + 20)

                    Spacer()
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Light — In Tune") {
    TunerDialView(cents: 0, noteName: "A", octave: 4)
        .preferredColorScheme(.light)
}

#Preview("Light — Sharp") {
    TunerDialView(cents: 22, noteName: "C", octave: 5)
        .preferredColorScheme(.light)
}

#Preview("Dark — Flat") {
    TunerDialView(cents: -35, noteName: "G", octave: 3)
        .preferredColorScheme(.dark)
}

//
//  Color+Extension.swift
//  Tune
//
//  Created by Brian O’Byrne on 3/10/26.
//

import SwiftUI

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

    // Color Indicators
    static let accuracyGreenBright = Color.green
    static let accuracyGreen = Color.green
    static let accuracyOrange = Color.orange
    static let accuracyYellow = Color.yellow
    static let accuracyRed = Color.red

    // Needle
    static let noSignalNeedle = Color(hex: "#0f5a29")
}

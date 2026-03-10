//
//  TunerUtilities.swift
//  Tune
//
//  Created by Brian O'Byrne on 2/26/26.
//

import SwiftUI

// MARK: - Cents Formatting & Color

extension Double {
    /// Returns a color indicating tuning accuracy based on cents deviation
    var tuningAccuracyColor: Color {
        switch abs(self) {
        case ..<1: return .accuracyGreenBright
        case ..<11: return .accuracyGreen
        case ..<21: return .accuracyYellow
        case ..<31: return .accuracyOrange
        default:    return .accuracyRed
        }
    }
    
    /// Formats cents value as a display string (e.g., "+10¢", "in tune")
    var formattedCentsLabel: String {
        if abs(self) < 0.5 { return "in tune" }
        return self > 0 ? String(format: "+%.0f¢", self) : String(format: "%.0f¢", self)
    }
}

// MARK: - Environment Keys

private struct HasSignalKey: EnvironmentKey {
    static let defaultValue: Bool = true
}

extension EnvironmentValues {
    var hasSignal: Bool {
        get { self[HasSignalKey.self] }
        set { self[HasSignalKey.self] = newValue }
    }
}

// MARK: - Frequency Formatting

extension Float {
    /// Formats frequency for display (e.g., "440.0 Hz")
    var formattedFrequency: String {
        String(format: "%.1f Hz", self)
    }
}

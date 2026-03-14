//
//  AppColorScheme.swift
//  Tune
//
//  Created by Brian O'Byrne on 3/14/26.
//

import SwiftUI

enum AppColorScheme: String, CaseIterable {
    case system
    case light
    case dark

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }

    var label: String {
        switch self {
        case .system: return "auto"
        case .light:  return "light"
        case .dark:   return "dark"
        }
    }
}

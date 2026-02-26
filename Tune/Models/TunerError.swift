//
//  TunerError.swift
//  Tune
//
//  Created by Brian O'Byrne on 2/26/26.
//

import Foundation

enum TunerError: Error, LocalizedError {
    case microphoneUnavailable

    var errorDescription: String? {
        switch self {
        case .microphoneUnavailable:
            return "Microphone unavailable. Please grant microphone access in Settings."
        }
    }
}

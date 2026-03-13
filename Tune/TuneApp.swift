//
//  TuneApp.swift
//  Tune
//
//  Created by Brian O’Byrne on 2/25/26.
//

import AVFoundation
import AudioKit
import SwiftUI

@main
struct TuneApp: App {
    @Environment(\.scenePhase) var scenePhase
    @State private var tuner = TunerEngine()

    init() {
        do {
            // Smaller buffer sizes reduce latency
            Settings.bufferLength = .short

            let audioSession = AVAudioSession.sharedInstance()

            try audioSession.setPreferredIOBufferDuration(
                Settings.bufferLength.duration
            )
            try audioSession.setCategory(
                .playAndRecord,
                options: [
                    .defaultToSpeaker,
                    .allowBluetoothA2DP,
                ]
            )
            try audioSession.setActive(true)

        } catch let err {

            print(err)
        }
        print("app initialized")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(tuner)
        }
    }
}

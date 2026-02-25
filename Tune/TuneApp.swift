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

    init() {
        #if os(iOS)
        do {
            Settings.bufferLength = .short

            // Settings.sampleRate default is 44_100
            if #available(iOS 18.0, *) {
                if !ProcessInfo.processInfo.isMacCatalystApp
                    && !ProcessInfo.processInfo.isiOSAppOnMac
                {
                    // Set samplerRate for iOS 18 and newer
                    Settings.sampleRate = 48_000
                }
            }

            try AVAudioSession.sharedInstance()
                .setPreferredIOBufferDuration(
                    Settings.bufferLength.duration
                )
            try AVAudioSession.sharedInstance().setCategory(
                .playAndRecord,
                options: [
                    .defaultToSpeaker, .mixWithOthers, .allowBluetoothA2DP,
                ]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let err {
            print(err)
        }
#endif
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

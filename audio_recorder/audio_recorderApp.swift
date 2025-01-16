//
//  audio_recorderApp.swift
//  audio_recorder
//
//  Created by Anastasiya Masalava on 1/15/25.
//

import SwiftUI
import FirebaseCore

@main
struct audio_recorderApp: App {
    init() {
            FirebaseApp.configure()
        }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

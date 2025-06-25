// EchoWellApp.swift

import SwiftUI
import AVFoundation

@main
struct EchoWellApp: App {
  @State private var didLaunch = false

  init() {
    // background audio session setup (rămâne neschimbat)
    do {
      let session = AVAudioSession.sharedInstance()
      try session.setCategory(.playback, mode: .default, options: [])
      try session.setActive(true)
    } catch {
      print("AVAudioSession setup failed:", error)
    }
  }

  var body: some Scene {
    WindowGroup {
      if didLaunch {
        ContentView()
      } else {
        WelcomeView(didLaunch: $didLaunch)
      }
    }
  }
}

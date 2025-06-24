import SwiftUI
import AVFoundation

@main
struct EchoWellApp: App {
  init() {
    // enable background playback
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
      ContentView()
            .environmentObject(AudioManager())// Asigură-te că aici stă ContentView, nu ClipsListView
    }
  }
}

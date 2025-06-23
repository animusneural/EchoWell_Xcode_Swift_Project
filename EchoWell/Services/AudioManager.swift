import Foundation
#if os(iOS)
import AVFoundation
#endif
import Combine

class AudioManager: ObservableObject {
  #if os(iOS)
  private var recorder: AVAudioRecorder?
  private var player: AVAudioPlayer? {
    didSet {
      player?.delegate = delegateHolder
    }
  }

  @Published var isPlaying: Bool = false
  private lazy var delegateHolder = AudioPlayerDelegate(self)
  #endif

  // Read dynamic config values
  private var config = Config.shared
  var sampleRate: Double { config.sampleRate }
  var duration: TimeInterval { config.recordDuration }

  init() {
    #if os(iOS)
    let session = AVAudioSession.sharedInstance()
    try? session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
    try? session.setActive(true)
    session.requestRecordPermission { granted in
      if !granted {
        print("⚠️ Microphone permission denied")
      }
    }
    #endif
  }

  func startRecording(to url: URL) {
    #if os(iOS)
    let session = AVAudioSession.sharedInstance()
    guard session.recordPermission == .granted else {
      print("🔒 No record permission")
      return
    }
    let settings: [String: Any] = [
      AVFormatIDKey: Int(kAudioFormatLinearPCM),
      AVSampleRateKey: sampleRate,
      AVNumberOfChannelsKey: 1,
      AVLinearPCMBitDepthKey: 16,
    ]
    do {
      recorder = try AVAudioRecorder(url: url, settings: settings)
      recorder?.record(forDuration: duration)
    } catch {
      print("❌ Recording failed:", error)
    }
    #endif
  }

  func stopRecording() {
    #if os(iOS)
    recorder?.stop()
    #endif
  }

  func playClip(at url: URL) {
    #if os(iOS)
    if let p = player, p.url == url, p.isPlaying {
      p.pause()
      isPlaying = false
    } else {
      do {
        player = try AVAudioPlayer(contentsOf: url)
        player?.play()
        isPlaying = true
      } catch {
        print("❌ Playback failed:", error)
        isPlaying = false
      }
    }
    #endif
  }
}

#if os(iOS)
private class AudioPlayerDelegate: NSObject, AVAudioPlayerDelegate {
  weak var manager: AudioManager?
  init(_ manager: AudioManager) { self.manager = manager }
  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    manager?.isPlaying = false
  }
}
#endif

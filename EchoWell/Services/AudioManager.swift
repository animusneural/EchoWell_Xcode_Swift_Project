import Foundation
#if os(iOS)
import AVFoundation
#endif
import Combine

/// Manages audio recording & playback.
class AudioManager: ObservableObject {
  #if os(iOS)
  private var recorder: AVAudioRecorder?
  private var player: AVAudioPlayer? {
    didSet { player?.delegate = delegateHolder }
  }

  @Published var isPlaying: Bool = false
  private lazy var delegateHolder = AudioPlayerDelegate(self)
  #endif

  // MARK: Config‐backed
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

  /// Starts recording until `stopRecording()` is called.
  func startRecording(to url: URL) {
    #if os(iOS)
    guard AVAudioSession.sharedInstance().recordPermission == .granted else {
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
      recorder?.record()
    } catch {
      print("❌ Recording failed:", error)
    }
    #endif
  }

  /// Stops whichever recording is in progress.
  func stopRecording() {
    #if os(iOS)
    recorder?.stop()
    #endif
  }

  /// Toggles playback of the given file.
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

  /// Pauses playback (if currently playing)
  func pauseClip() {
    #if os(iOS)
    player?.pause()
    isPlaying = false
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

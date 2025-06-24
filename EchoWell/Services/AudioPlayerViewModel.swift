import Foundation
import AVFoundation
import Combine

/// Manages AVAudioPlayer for a single clip.
class AudioPlayerViewModel: ObservableObject {
  @Published var isPlaying = false
  @Published var currentTime: TimeInterval = 0
  @Published var duration: TimeInterval = 0

  private var player: AVAudioPlayer!
  private var timer: AnyCancellable?

  /// Initialize with the clip’s local file URL.
  init(fileURL: URL) {
    do {
      player = try AVAudioPlayer(contentsOf: fileURL)
      duration = player.duration
      player.prepareToPlay()
      // observe playback position
      timer = Timer.publish(every: 0.1, on: .main, in: .common)
        .autoconnect()
        .sink { [weak self] _ in
          guard let self = self, self.player.isPlaying else { return }
          self.currentTime = self.player.currentTime
        }
    } catch {
      print("Audio init failed:", error)
    }
  }

  func play() {
    guard !player.isPlaying else { return }
    player.play()
    isPlaying = true
  }

  func pause() {
    guard player.isPlaying else { return }
    player.pause()
    isPlaying = false
  }

  func seek(to time: TimeInterval) {
    player.currentTime = time
    currentTime = time
    if isPlaying { player.play() }
  }
}

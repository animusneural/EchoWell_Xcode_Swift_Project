// Models/EchoClip.swift

import Foundation
#if os(iOS)
import AVFoundation
#endif

/// A single recorded clip entry.
struct EchoClip: Identifiable, Codable {
  let id: Int64
  let filename: String
  let timestamp: Date
  let contextTag: String
  let person: String
  let note: String

  /// Computed URL for playback/export
  var fileURL: URL {
    let docs = try! FileManager.default
      .url(for: .documentDirectory, in: .userDomainMask,
           appropriateFor: nil, create: true)
    return docs.appendingPathComponent(filename)
  }

  #if os(iOS)
  /// Duration in whole seconds
  var durationSeconds: Int? {
    do {
      let file = try AVAudioFile(forReading: fileURL)
      let sampleRate = file.fileFormat.sampleRate
      let length = file.length                            // total frames
      // duration = frames ÷ sampleRate
      let seconds = Double(length) / sampleRate
      return Int(seconds.rounded(.down))
    } catch {
      return nil
    }
  }
  #else
  var durationSeconds: Int? { nil }
  #endif
}

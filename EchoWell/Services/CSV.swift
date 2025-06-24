// Services/CSV.swift
import Foundation

/// Renders an array of EchoClip as a CSV string.
func generateCSV(from clips: [EchoClip]) -> String {
  let header = ["Filename","Timestamp","Person","Tag","Note"]
  let rows = clips.map { clip in
    [
      clip.filename,
      ISO8601DateFormatter().string(from: clip.timestamp),
      clip.person,
      clip.contextTag,
      clip.note.replacingOccurrences(of: "\n", with: " ")
    ]
  }
  return ([header] + rows)
    .map { $0.joined(separator: ",") }
    .joined(separator: "\n")
}

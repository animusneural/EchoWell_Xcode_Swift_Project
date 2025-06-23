import Foundation

struct EchoClip: Identifiable, Codable {
  let id: Int64
  let filename: String
  let timestamp: Date
  let contextTag: String
  let person: String
  let note: String
}

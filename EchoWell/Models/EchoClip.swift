import Foundation

struct EchoClip: Identifiable {
  let id: Int64
  let filename: String
  let timestamp: Date
  let contextTag: String
  let person: String       // who was selected
  let note: String         // custom text entered
}

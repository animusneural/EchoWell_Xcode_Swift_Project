// App/Models/ClipFilter.swift

import Foundation

struct ClipFilter {
  var tag: String?       = nil
  var person: String?    = nil
  var fromDate: Date?    = nil
  var toDate: Date?      = nil

  func matches(_ clip: EchoClip) -> Bool {
    if let tag = tag, !tag.isEmpty, clip.contextTag.lowercased() != tag.lowercased() {
      return false
    }
    if let p = person, !p.isEmpty, clip.person.lowercased() != p.lowercased() {
      return false
    }
    if let from = fromDate, clip.timestamp < from {
      return false
    }
    if let to = toDate, clip.timestamp > to {
      return false
    }
    return true
  }
}

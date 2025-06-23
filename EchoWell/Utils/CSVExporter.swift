//
//  CSVExporter.swift
//  EchoWell
//
//  Created by Matei Grigore on 6/23/25.
//

import Foundation

func generateCSV(from clips: [EchoClip]) -> String {
  var csv = "ClipID,Filename,Timestamp,Person,Tag,Note\n"
  let formatter = ISO8601DateFormatter()
  for c in clips {
    let ts = formatter.string(from: c.timestamp)
    let fields = [
      String(c.id),
      c.filename,
      ts,
      c.person,
      c.contextTag,
      c.note
    ]
    // Quote any commas
    let line = fields.map { "\"\($0)\"" }.joined(separator: ",")
    csv += line + "\n"
  }
  return csv
}

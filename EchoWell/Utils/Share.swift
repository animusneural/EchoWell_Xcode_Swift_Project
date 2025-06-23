//
//  Share.swift
//  EchoWell
//
//  Created by Matei Grigore on 6/23/25.
//

import SwiftUI
import UIKit

func presentShareSheet(with csv: String, filename: String) {
  // Write CSV to a temporary file
  let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
  try? csv.data(using: .utf8)?.write(to: tempURL)

  let activityVC = UIActivityViewController(
    activityItems: [tempURL],
    applicationActivities: nil
  )
  // Present from the key window’s root view controller
  if let root = UIApplication.shared.connectedScenes
       .compactMap({ ($0 as? UIWindowScene)?.windows.first })
       .first?.rootViewController
  {
    root.present(activityVC, animated: true, completion: nil)
  }
}

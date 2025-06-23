//
//  EchoWellTests.swift
//  EchoWellTests
//
//  Created by Matei Grigore on 6/23/25.
//

import XCTest
@testable import EchoWell  // your app module name

final class DatabaseTests: XCTestCase {
  var db: Database!
  var tempDBURL: URL!

  override func setUpWithError() throws {
    // Redirect the database to a temporary file for isolation
    let tmpDir = FileManager.default.temporaryDirectory
    tempDBURL = tmpDir.appendingPathComponent("test_echo_well.sqlite3")
    // Remove any stale file
    try? FileManager.default.removeItem(at: tempDBURL)

    // Swap Database.shared.db to use tempDBURL
    db = try Database(testingPath: tempDBURL.path)
  }

  override func tearDownWithError() throws {
    // Clean up
    try? FileManager.default.removeItem(at: tempDBURL)
    db = nil
  }

  func testInsertFetchDeleteCycle() throws {
    // 1) No clips initially
    XCTAssertTrue(db.fetchAll().isEmpty)

    // 2) Insert one clip
    let fakeURL = URL(fileURLWithPath: "/tmp/audio.wav")
    db.insertClip(url: fakeURL, tag: "play", person: "Alice", note: "Test")
    
    // 3) Fetch gives one clip with correct metadata
    let clips = db.fetchAll()
    XCTAssertEqual(clips.count, 1)
    let clip = clips[0]
    XCTAssertEqual(clip.filename, "audio.wav")
    XCTAssertEqual(clip.contextTag, "play")
    XCTAssertEqual(clip.person, "Alice")
    XCTAssertEqual(clip.note, "Test")

    // 4) Delete it
    db.deleteClip(clip)
    XCTAssertTrue(db.fetchAll().isEmpty)
  }
}

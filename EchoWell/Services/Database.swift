//
//  Database.swift
//  EchoWell
//
//  Created by Matei Grigore on 6/22/25.
//

import Foundation
import SQLite    // from SQLite.swift
import Combine

/// Manages persistence of audio clips (tag, person, note) in a local SQLite database,
/// and migrates existing tables to add missing columns automatically.
class Database: ObservableObject {
  static let shared = Database()

  private var db: Connection
  private let clips = Table("EchoClips")

  // MARK: — Column expressions
  private let id         = Expression<Int64>("ClipID")
  private let filename   = Expression<String>("Filename")
  private let timestamp  = Expression<Date>("Timestamp")
  private let contextTag = Expression<String>("ContextTag")
  private let colPerson  = Expression<String>("Person")
  private let colNote    = Expression<String>("Note")

  /// The main initializer used at runtime
  private init() {
    // 1) Open or create the SQLite file in Documents/
    let url = try! FileManager.default
      .url(
        for: .documentDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true
      )
      .appendingPathComponent("echo_well.sqlite3")
    db = try! Connection(url.path)

    // 2) Create the base table if missing (old 4-column schema)
    try! db.run(clips.create(ifNotExists: true) { t in
      t.column(id, primaryKey: .autoincrement)
      t.column(filename)
      t.column(timestamp, defaultValue: Date())
      t.column(contextTag)
      // Person & Note omitted here; added below via ALTER
    })

    // 3) Migrate: add Person column if missing
    do {
      try db.run(
        "ALTER TABLE \"EchoClips\" ADD COLUMN \"Person\" TEXT NOT NULL DEFAULT ''"
      )
    } catch {
      // ignore if column already exists
    }

    // 4) Migrate: add Note column if missing
    do {
      try db.run(
        "ALTER TABLE \"EchoClips\" ADD COLUMN \"Note\" TEXT NOT NULL DEFAULT ''"
      )
    } catch {
      // ignore if column already exists
    }
  }

  #if DEBUG
  /// Special initializer for unit tests, pointing at a custom filepath
  /// so tests don’t touch the real user database.
  convenience init(testingPath path: String) throws {
    self.init()     // run all the normal migrations against the *default* DB
    // then re-open `db` to point at your test path:
    db = try Connection(path)
    // ensure schema exists in the test DB as well:
    try db.run(clips.create(ifNotExists: true) { t in
      t.column(id, primaryKey: .autoincrement)
      t.column(filename)
      t.column(timestamp, defaultValue: Date())
      t.column(contextTag)
      t.column(colPerson)
      t.column(colNote)
    })
  }
  #endif

  // MARK: — Insert

  /// Inserts a new clip record.
  func insertClip(
    url: URL,
    tag: String,
    person: String,
    note: String
  ) {
    let insert = clips.insert(
      filename    <- url.lastPathComponent,
      timestamp   <- Date(),
      contextTag  <- tag,
      colPerson   <- person,
      colNote     <- note
    )
    _ = try? db.run(insert)
  }

  // MARK: — Fetch

  /// Returns all saved clips, most recent first, including person & note.
  func fetchAll() -> [EchoClip] {
    (try? db.prepare(clips.order(id.desc)).map { row in
      EchoClip(
        id:          row[id],
        filename:    row[filename],
        timestamp:   row[timestamp],
        contextTag:  row[contextTag],
        person:      row[colPerson],
        note:        row[colNote]
      )
    }) ?? []
  }

  // MARK: — Delete

  /// Deletes both the database row and the corresponding audio file.
  func deleteClip(_ clip: EchoClip) {
    _ = try? db.run(clips.filter(id == clip.id).delete())
    if let fileURL = try? FileManager.default
      .url(
        for: .documentDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true
      )
      .appendingPathComponent(clip.filename)
    {
      _ = try? FileManager.default.removeItem(at: fileURL)
    }
  }
}

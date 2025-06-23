//
//  EchoWellUITests.swift
//  EchoWellUITests
//
//  Created by Matei Grigore on 6/23/25.
//

import XCTest

final class EchoWellUITests: XCTestCase {
  var app: XCUIApplication!

  override func setUpWithError() throws {
    continueAfterFailure = false
    app = XCUIApplication()
    app.launch()
  }

  func testRecordPlayDeleteExportAnalytics() throws {
    // 1) Record a clip
    let recordButton = app.buttons["Record"]
    XCTAssertTrue(recordButton.exists)
    recordButton.tap()
    
    // Wait 1 second, then stop
    sleep(1)
    app.buttons["Stop"].tap()

    // 2) Switch to Library tab
    app.tabBars.buttons["Library"].tap()
    XCTAssertTrue(app.staticTexts["play"].exists) // check tag label

    // 3) Play clip
    let playButton = app.buttons.matching(identifier: "play.circle").firstMatch
    XCTAssertTrue(playButton.exists)
    playButton.tap()

    // 4) Delete via swipe
    let firstCell = app.cells.firstMatch
    firstCell.swipeLeft()
    firstCell.buttons["Delete"].tap()
    XCTAssertFalse(firstCell.exists)

    // 5) Export data
    app.tabBars.buttons["Settings"].tap()
    let exportButton = app.buttons["Export All Clips as CSV"]
    XCTAssertTrue(exportButton.exists)
    exportButton.tap()
    // System share sheet appears—dismiss it
    app.swipeDown()
    
    // 6) Analytics tab
    app.tabBars.buttons["Analytics"].tap()
    XCTAssertTrue(app.staticTexts["Clips per Day"].exists)
    XCTAssertTrue(app.staticTexts["Tag Distribution"].exists)
  }
}

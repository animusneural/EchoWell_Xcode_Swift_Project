import XCTest

final class EchoWellUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        
        // Enable accessibility explicitly for UI testing
        app.launchArguments += ["-AppleAccessibilityEnabled", "YES"]
        
        // Optional: Set preferred content size category for accessibility testing
        app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityMedium"]
        
        app.launch()
        
        // Wait for a known UI element to appear before proceeding
        // This ensures the app and accessibility system are ready
        let startButton = app.buttons["Începe"]
        let exists = startButton.waitForExistence(timeout: 60) // Increase timeout

        print(app.debugDescription) // Print UI hierarchy for debugging

        XCTAssertTrue(exists, "App did not load accessibility in time or 'Începe' button not found")
    }

    func testExampleFlow() throws {
        // Example test that taps the "Începe" button to start

        let startButton = app.buttons["Începe"]
        XCTAssertTrue(startButton.exists, "'Începe' button should exist")
        startButton.tap()

        // Continue with further UI interactions, e.g., recording, playing, deleting clips
        // Add waits before interacting with elements to ensure stability

        // Example: Wait for Record button and tap it
        let recordButton = app.buttons["recordButton"]
        XCTAssertTrue(recordButton.waitForExistence(timeout: 10), "Record button should exist")
        recordButton.tap()

        // Add your further test steps here...
        
        // 3) Wait for Stop button to appear (indicating recording started)
        let stopButton = app.buttons["recordButton"] // same button toggles state
        XCTAssertTrue(stopButton.waitForExistence(timeout: 5), "Stop button should appear after recording starts")
        
        // Simulate 1 second recording (optional)
        sleep(1)
        
        stopButton.tap()
        
        // 4) Switch to Library tab
     /*   let libraryTab = app.tabBars.buttons["Library"]
        XCTAssertTrue(libraryTab.waitForExistence(timeout: 5), "Library tab should exist")
        libraryTab.tap()
        
        // 5) Wait for at least one clip cell to appear
        let firstCell = app.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5), "At least one clip cell should exist in Library")
        
        // 6) Find the Play button inside the first cell and tap it
        let playButton = firstCell.buttons["playButton"]
        XCTAssertTrue(playButton.waitForExistence(timeout: 5), "Play button should be visible in the first clip cell")
        playButton.tap()
        */
        
        let libraryTab = app.tabBars.buttons["Library"]
        XCTAssertTrue(libraryTab.waitForExistence(timeout: 5), "Library tab should exist")
        libraryTab.tap()

        let firstCell = app.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5), "At least one clip cell should exist in Library")

        let playButton = firstCell.buttons["play.circle"]
        XCTAssertTrue(playButton.waitForExistence(timeout: 5), "Play button should be visible in the first clip cell")
        playButton.tap()
        
        // 7) Delete via swipe on the first cell
        firstCell.swipeLeft()
        
        let deleteButton = firstCell.buttons.matching(NSPredicate(format: "label == %@", "Delete")).firstMatch
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 5), "Delete button should appear after swipe")
        deleteButton.tap()
        
        // Wait for cell to be deleted
        let doesNotExist = NSPredicate(format: "exists == false")
        expectation(for: doesNotExist, evaluatedWith: firstCell, handler: nil)
        waitForExpectations(timeout: 5)
        
        // 8) Export data
        let settingsTab = app.tabBars.buttons["Settings"]
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5), "Settings tab should exist")
        settingsTab.tap()
        
        let exportButton = app.buttons["Export as CSV"]
        XCTAssertTrue(exportButton.waitForExistence(timeout: 5), "Export button should exist in Settings")
        exportButton.tap()
        
        // Dismiss system share sheet
        let cancelButton = app.buttons["Cancel"]
        if cancelButton.waitForExistence(timeout: 5) {
            cancelButton.tap()
        } else {
            // fallback: tap outside to dismiss
            app.tap()
        }
        
        // 9) Analytics tab
        let analyticsTab = app.tabBars.buttons["Analytics"]
        XCTAssertTrue(analyticsTab.waitForExistence(timeout: 5), "Analytics tab should exist")
        analyticsTab.tap()
        
        XCTAssertTrue(app.staticTexts["Clips per Day"].waitForExistence(timeout: 5), "Clips per Day label should exist")
        XCTAssertTrue(app.staticTexts["Tag Distribution"].waitForExistence(timeout: 5), "Tag Distribution label should exist")
        
    }
}

//
//  EchoWellUITestsLaunchTests.swift
//  EchoWellUITests
//
//  Created by Matei Grigore on 6/23/25.
//

import XCTest

final class EchoWellUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()

        // Enable accessibility explicitly for UI testing
        app.launchArguments += ["-AppleAccessibilityEnabled", "YES"]

        // Launch the app
        app.launch()

        // Small delay to allow accessibility system to initialize
        sleep(1)

        // Debug: print UI hierarchy to console for inspection
        print(app.debugDescription)

        // Wait for the "Începe" button to appear, increase timeout to 60 seconds
        let startButton = app.buttons["Începe"]
        let exists = startButton.waitForExistence(timeout: 60)
        XCTAssertTrue(exists, "App did not load accessibility in time or 'Începe' button not found")

        // Take a screenshot after app launch and accessibility is ready
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}

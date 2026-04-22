import XCTest

/// Screenshot tests for the Picsum Demo iOS app.
///
/// All tests use the real Lorem Picsum API — no mocks, no hardcoded data.
/// Photos are loaded live over the network; tests wait for real cells to appear.
///
/// Run via:
///   bash scripts/ios_screenshots.sh
final class PicsumDemoScreenshots: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        // Disable animations so the UI settles immediately after data loads.
        app.launchArguments += ["-UIAnimationDragCoefficient", "0"]
    }

    // MARK: - Helpers

    private func save(_ name: String) {
        let screenshot = app.screenshot()
        let att = XCTAttachment(screenshot: screenshot)
        att.name = name
        att.lifetime = .keepAlways
        add(att)
        print("📸 \(name)")
    }

    /// Wait for the first photo cell button to appear (real network call to picsum.photos).
    private func waitForPhotoGrid(timeout: TimeInterval = 30) -> XCUIElement {
        let cell = app.scrollViews.firstMatch.buttons.firstMatch
        XCTAssert(cell.waitForExistence(timeout: timeout), "Photo grid did not load within \(Int(timeout)) s")
        return cell
    }

    // MARK: - Screenshots

    /// Capture the photo grid with real Picsum photos fully loaded.
    func testPhotoGrid() throws {
        app.launch()
        _ = waitForPhotoGrid()
        // Allow extra time for thumbnails to download and render.
        sleep(12)
        save("ios_photo_grid")
    }

    /// Capture the photo detail sheet with a real Picsum image.
    func testPhotoDetail() throws {
        app.launch()
        let cell = waitForPhotoGrid()
        sleep(8) // let thumbnails render before tapping
        cell.tap()
        // Wait for the detail image to download from picsum.photos.
        sleep(12)
        save("ios_photo_detail")
    }
}

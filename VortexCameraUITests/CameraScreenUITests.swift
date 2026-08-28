import XCTest

final class CameraScreenUITests: XCTestCase {
    func testOnboardingShowsCameraLaunchAction() {
        let app = XCUIApplication()
        app.launchArguments += ["-hasCompletedOnboarding", "NO"]
        app.launch()
        XCTAssertTrue(app.buttons["Devam"].exists || app.buttons["Kamerayı Aç"].exists)
    }
}

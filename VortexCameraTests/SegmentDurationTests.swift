import XCTest
@testable import VortexCamera

final class SegmentDurationTests: XCTestCase {
    func testDefaultSegmentIsSixtySeconds() {
        XCTAssertEqual(SegmentDuration.seconds60.rawValue, 60)
    }

    func testSingleFileHasNoRotationInterval() {
        XCTAssertEqual(SegmentDuration.singleFile.rawValue, 0)
    }
}

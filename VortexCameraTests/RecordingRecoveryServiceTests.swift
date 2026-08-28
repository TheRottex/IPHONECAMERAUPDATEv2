import XCTest
@testable import VortexCamera

final class RecordingRecoveryServiceTests: XCTestCase {
    func testRecoveryReturnsOnlySegmentsWhoseFilesExist() throws {
        let existing = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mov")
        FileManager.default.createFile(atPath: existing.path, contents: Data())
        defer { try? FileManager.default.removeItem(at: existing) }
        let missing = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mov")
        let segment = RecordingSegment(id: UUID(), url: existing, startedAt: .now, duration: 2, fileSize: 0)
        let missingSegment = RecordingSegment(id: UUID(), url: missing, startedAt: .now, duration: 2, fileSize: 0)
        let recovery = RecordingRecoveryService(storage: StubStorage(segments: [segment, missingSegment]))
        XCTAssertEqual(recovery.recoverCompletedSegments(), [segment])
    }
}

private final class StubStorage: MediaStoring {
    let segments: [RecordingSegment]
    init(segments: [RecordingSegment]) { self.segments = segments }
    func recordingsDirectory() throws -> URL { FileManager.default.temporaryDirectory }
    func makeSegmentURL() throws -> URL { FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString) }
    func completedSegments() -> [RecordingSegment] { segments }
    func persist(_ segments: [RecordingSegment]) throws { }
}

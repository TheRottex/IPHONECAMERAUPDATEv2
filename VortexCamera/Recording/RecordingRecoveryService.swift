import Foundation

final class RecordingRecoveryService {
    private let storage: MediaStoring

    init(storage: MediaStoring) { self.storage = storage }

    func recoverCompletedSegments() -> [RecordingSegment] {
        storage.completedSegments().filter { FileManager.default.fileExists(atPath: $0.url.path) }
    }
}

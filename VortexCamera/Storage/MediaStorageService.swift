import Foundation

protocol MediaStoring {
    func recordingsDirectory() throws -> URL
    func makeSegmentURL() throws -> URL
    func completedSegments() -> [RecordingSegment]
    func persist(_ segments: [RecordingSegment]) throws
}

final class MediaStorageService: MediaStoring {
    private let fileManager: FileManager
    private let metadataURL: URL

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        let base = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        self.metadataURL = base.appendingPathComponent("VortexCamera/recordings.json")
    }

    func recordingsDirectory() throws -> URL {
        let url = metadataURL.deletingLastPathComponent().appendingPathComponent("Segments", isDirectory: true)
        try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    func makeSegmentURL() throws -> URL { try recordingsDirectory().appendingPathComponent("segment-\(UUID().uuidString).mov") }
    func completedSegments() -> [RecordingSegment] { (try? Data(contentsOf: metadataURL)).flatMap { try? JSONDecoder().decode([RecordingSegment].self, from: $0) } ?? [] }
    func persist(_ segments: [RecordingSegment]) throws {
        try fileManager.createDirectory(at: metadataURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try JSONEncoder().encode(segments).write(to: metadataURL, options: .atomic)
    }
}

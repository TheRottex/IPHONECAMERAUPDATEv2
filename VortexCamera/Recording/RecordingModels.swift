import Foundation

enum SegmentDuration: TimeInterval, CaseIterable, Identifiable {
    case seconds30 = 30, seconds60 = 60, minutes2 = 120, minutes5 = 300, singleFile = 0
    var id: TimeInterval { rawValue }
    var title: String { self == .singleFile ? "Tek dosya" : rawValue < 60 ? "30 sn" : rawValue == 60 ? "60 sn" : rawValue == 120 ? "2 dk" : "5 dk" }
}

struct RecordingSegment: Codable, Identifiable, Equatable {
    let id: UUID
    let url: URL
    let startedAt: Date
    let duration: TimeInterval
    let fileSize: Int64
}

struct RecordingSummary {
    let segments: [RecordingSegment]
    let recoveredSegments: [RecordingSegment]
    var totalDuration: TimeInterval { segments.reduce(0) { $0 + $1.duration } }
    var totalFileSize: Int64 { segments.reduce(0) { $0 + $1.fileSize } }
}

enum RecordingError: LocalizedError {
    case cannotStart(String)
    case noVideoFrames
    var errorDescription: String? { switch self { case .cannotStart(let message): return message; case .noVideoFrames: return "Video kareleri alınamadı." } }
}

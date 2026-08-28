import AVFoundation

final class SegmentMerger {
    func merge(_ segments: [RecordingSegment], destination: URL) async throws -> URL {
        let composition = AVMutableComposition()
        guard let track = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else { throw CocoaError(.fileWriteUnknown) }
        var cursor = CMTime.zero
        for segment in segments {
            let asset = AVURLAsset(url: segment.url)
            guard let source = try await asset.loadTracks(withMediaType: .video).first else { continue }
            let duration = try await asset.load(.duration)
            try track.insertTimeRange(.init(start: .zero, duration: duration), of: source, at: cursor)
            cursor = cursor + duration
        }
        guard let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            throw CocoaError(.fileWriteUnknown)
        }
        exporter.outputURL = destination
        exporter.outputFileType = .mov
        try await withCheckedThrowingContinuation { continuation in
            exporter.exportAsynchronously {
                if exporter.status == .completed {
                    continuation.resume(returning: ())
                } else {
                    continuation.resume(throwing: exporter.error ?? CocoaError(.fileWriteUnknown))
                }
            }
        }
        return destination
    }
}

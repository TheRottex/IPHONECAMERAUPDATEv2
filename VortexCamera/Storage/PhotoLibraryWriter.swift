import Photos

final class PhotoLibraryWriter {
    func saveVideo(at url: URL) async throws {
        try await withCheckedThrowingContinuation { continuation in
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            } completionHandler: { success, error in
                if success { continuation.resume() } else { continuation.resume(throwing: error ?? CocoaError(.fileWriteUnknown)) }
            }
        }
    }
}

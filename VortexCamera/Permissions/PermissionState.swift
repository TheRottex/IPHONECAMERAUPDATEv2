import AVFoundation
import Photos

struct PermissionSnapshot: Equatable {
    var camera: AVAuthorizationStatus
    var microphone: AVAuthorizationStatus
    var photoLibrary: PHAuthorizationStatus

    var canUseCamera: Bool { camera == .authorized }
    var canRecordAudio: Bool { microphone == .authorized }
    var canAddToPhotoLibrary: Bool { photoLibrary == .authorized || photoLibrary == .limited }

    static let unavailable = PermissionSnapshot(camera: .notDetermined, microphone: .notDetermined, photoLibrary: .notDetermined)
}

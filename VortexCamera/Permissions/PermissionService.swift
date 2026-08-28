import AVFoundation
import Photos
import UIKit

protocol PermissionProviding {
    func current() -> PermissionSnapshot
    func requestCamera() async -> Bool
    func requestMicrophone() async -> Bool
    func requestPhotoLibrary() async -> Bool
}

final class PermissionService: PermissionProviding {
    func current() -> PermissionSnapshot {
        PermissionSnapshot(
            camera: AVCaptureDevice.authorizationStatus(for: .video),
            microphone: AVCaptureDevice.authorizationStatus(for: .audio),
            photoLibrary: PHPhotoLibrary.authorizationStatus(for: .addOnly)
        )
    }

    func requestCamera() async -> Bool {
        await AVCaptureDevice.requestAccess(for: .video)
    }

    func requestMicrophone() async -> Bool {
        await AVCaptureDevice.requestAccess(for: .audio)
    }

    func requestPhotoLibrary() async -> Bool {
        await PHPhotoLibrary.requestAuthorization(for: .addOnly) == .authorized
    }

    @MainActor
    static func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

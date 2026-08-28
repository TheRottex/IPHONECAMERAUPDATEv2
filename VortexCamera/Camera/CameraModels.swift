import AVFoundation
import CoreGraphics

enum CameraPosition: String, CaseIterable, Identifiable {
    case back, front
    var id: String { rawValue }
    var avPosition: AVCaptureDevice.Position { self == .back ? .back : .front }
}

enum CameraMode: String, CaseIterable, Identifiable {
    case video = "VIDEO"
    case photo = "PHOTO"
    var id: String { rawValue }
}

enum CameraPhase: Equatable {
    case permissionRequired
    case configuring
    case ready
    case recording
    case interrupted(String)
    case failed(String)
}

struct CameraLens: Identifiable, Equatable {
    let deviceType: AVCaptureDevice.DeviceType
    let displayName: String
    let zoomLabel: String
    var id: String { deviceType.rawValue }
}

struct CameraDiagnostics {
    var activeLens = "—"
    var format = "—"
    var fps = "—"
    var lastError = "—"
}

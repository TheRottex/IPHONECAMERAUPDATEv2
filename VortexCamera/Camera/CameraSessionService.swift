import AVFoundation
import Combine
import UIKit

protocol CameraSessionProviding: AnyObject {
    var session: AVCaptureSession { get }
    var eventPublisher: AnyPublisher<CameraSessionEvent, Never> { get }
    func configure(position: CameraPosition) async throws -> [CameraLens]
    func start() async
    func stop() async
    func switchCamera() async throws -> CameraPosition
    func selectLens(_ lens: CameraLens) async throws
    func focusAndExpose(at point: CGPoint) async
    func setZoom(_ factor: CGFloat) async
}

enum CameraSessionEvent {
    case interrupted(String)
    case runtimeError(String)
}

enum CameraServiceError: LocalizedError {
    case noCamera
    case cannotAddInput
    case configuration(String)

    var errorDescription: String? {
        switch self {
        case .noCamera: return "Bu cihazda kullanılabilir kamera bulunamadı."
        case .cannotAddInput: return "Kamera girişi oturuma eklenemedi."
        case .configuration(let message): return message
        }
    }
}

final class CameraSessionService: NSObject, CameraSessionProviding {
    let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "com.vortex.camera.session", qos: .userInitiated)
    private let events = PassthroughSubject<CameraSessionEvent, Never>()
    private var videoInput: AVCaptureDeviceInput?
    private var currentPosition: CameraPosition = .back

    var eventPublisher: AnyPublisher<CameraSessionEvent, Never> { events.eraseToAnyPublisher() }

    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(sessionInterrupted(_:)), name: .AVCaptureSessionWasInterrupted, object: session)
        NotificationCenter.default.addObserver(self, selector: #selector(runtimeError(_:)), name: .AVCaptureSessionRuntimeError, object: session)
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    func configure(position: CameraPosition) async throws -> [CameraLens] {
        try await perform {
            self.session.beginConfiguration()
            defer { self.session.commitConfiguration() }
            self.session.sessionPreset = .high
            self.removeInputs()
            guard let device = self.defaultDevice(position: position) else { throw CameraServiceError.noCamera }
            try self.addVideoInput(device)
            self.addAudioInputIfAuthorized()
            self.currentPosition = position
            return self.availableLenses(for: position)
        }
    }

    func start() async { await perform { if !self.session.isRunning { self.session.startRunning() } } }
    func stop() async { await perform { if self.session.isRunning { self.session.stopRunning() } } }

    func switchCamera() async throws -> CameraPosition {
        try await perform {
            let next: CameraPosition = self.currentPosition == .back ? .front : .back
            self.session.beginConfiguration()
            defer { self.session.commitConfiguration() }
            self.removeInputs()
            guard let device = self.defaultDevice(position: next) else { throw CameraServiceError.noCamera }
            try self.addVideoInput(device)
            self.currentPosition = next
            return next
        }
    }

    func selectLens(_ lens: CameraLens) async throws {
        try await perform {
            guard self.currentPosition == .back else { return }
            let discovery = AVCaptureDevice.DiscoverySession(deviceTypes: [lens.deviceType], mediaType: .video, position: .back)
            guard let device = discovery.devices.first else { throw CameraServiceError.noCamera }
            self.session.beginConfiguration()
            defer { self.session.commitConfiguration() }
            self.removeInputs()
            try self.addVideoInput(device)
        }
    }

    func focusAndExpose(at point: CGPoint) async {
        await perform {
            guard let device = self.videoInput?.device, device.isConnected else { return }
            do {
                try device.lockForConfiguration()
                if device.isFocusPointOfInterestSupported { device.focusPointOfInterest = point; device.focusMode = .autoFocus }
                if device.isExposurePointOfInterestSupported { device.exposurePointOfInterest = point; device.exposureMode = .continuousAutoExposure }
                device.unlockForConfiguration()
            } catch { self.events.send(.runtimeError(error.localizedDescription)) }
        }
    }

    func setZoom(_ factor: CGFloat) async {
        await perform {
            guard let device = self.videoInput?.device else { return }
            do {
                try device.lockForConfiguration()
                device.videoZoomFactor = min(max(1, factor), device.activeFormat.videoMaxZoomFactor)
                device.unlockForConfiguration()
            } catch { self.events.send(.runtimeError(error.localizedDescription)) }
        }
    }

    private func defaultDevice(position: CameraPosition) -> AVCaptureDevice? {
        AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position.avPosition)
    }

    private func availableLenses(for position: CameraPosition) -> [CameraLens] {
        guard position == .back else { return [CameraLens(deviceType: .builtInWideAngleCamera, displayName: "Front", zoomLabel: "1x")] }
        let types: [(AVCaptureDevice.DeviceType, String, String)] = [(.builtInUltraWideCamera, "Ultra Wide", "0.5x"), (.builtInWideAngleCamera, "Wide", "1x"), (.builtInTelephotoCamera, "Telephoto", "3x")]
        return types.compactMap { type, name, zoom in
            AVCaptureDevice.DiscoverySession(deviceTypes: [type], mediaType: .video, position: .back).devices.isEmpty ? nil : CameraLens(deviceType: type, displayName: name, zoomLabel: zoom)
        }
    }

    private func removeInputs() { session.inputs.forEach { session.removeInput($0) }; videoInput = nil }
    private func addVideoInput(_ device: AVCaptureDevice) throws {
        let input = try AVCaptureDeviceInput(device: device)
        guard session.canAddInput(input) else { throw CameraServiceError.cannotAddInput }
        session.addInput(input); videoInput = input
    }
    private func addAudioInputIfAuthorized() {
        guard AVCaptureDevice.authorizationStatus(for: .audio) == .authorized, let device = AVCaptureDevice.default(for: .audio), let input = try? AVCaptureDeviceInput(device: device), session.canAddInput(input) else { return }
        session.addInput(input)
    }
    private func perform<T>(_ operation: @escaping () throws -> T) async throws -> T { try await withCheckedThrowingContinuation { continuation in sessionQueue.async { continuation.resume(with: Result { try operation() }) } } }
    private func perform(_ operation: @escaping () -> Void) async { await withCheckedContinuation { continuation in sessionQueue.async { operation(); continuation.resume() } } }
    @objc private func sessionInterrupted(_ notification: Notification) { events.send(.interrupted("Kamera oturumu sistem tarafından kesildi.")) }
    @objc private func runtimeError(_ notification: Notification) { events.send(.runtimeError((notification.userInfo?[AVCaptureSessionErrorKey] as? Error)?.localizedDescription ?? "Kamera hatası.")) }
}

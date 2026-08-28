import Combine
import Foundation
import SwiftUI

@MainActor
final class CameraViewModel: ObservableObject {
    @Published private(set) var phase: CameraPhase = .permissionRequired
    @Published private(set) var lenses: [CameraLens] = []
    @Published private(set) var position: CameraPosition = .back
    @Published private(set) var elapsed: TimeInterval = 0
    @Published private(set) var summary: RecordingSummary?
    @Published var mode: CameraMode = .video
    @Published var selectedSegmentDuration: SegmentDuration = .seconds60
    @Published var isTouchLocked = false
    @Published var diagnostics = CameraDiagnostics()

    let sessionService: CameraSessionProviding
    let recordingService: SegmentedRecordingProviding
    let permissions: PermissionProviding
    let protection: RecordingProtectionService
    private var events = Set<AnyCancellable>()
    private var timer: Timer?

    init(sessionService: CameraSessionProviding = CameraSessionService(), permissions: PermissionProviding = PermissionService(), protection: RecordingProtectionService = RecordingProtectionService()) {
        self.sessionService = sessionService
        self.permissions = permissions
        self.protection = protection
        let recording = SegmentedRecordingService(storage: MediaStorageService())
        self.recordingService = recording
        sessionService.eventPublisher.receive(on: DispatchQueue.main).sink { [weak self] event in
            switch event { case .interrupted(let reason): self?.phase = .interrupted(reason); case .runtimeError(let reason): self?.diagnostics.lastError = reason }
        }.store(in: &events)
    }

    var isRecording: Bool { if case .recording = phase { return true }; return false }

    func prepare() async {
        let state = permissions.current()
        guard state.canUseCamera else { phase = .permissionRequired; return }
        phase = .configuring
        do {
            try recordingService.attach(to: sessionService.session)
            lenses = try await sessionService.configure(position: position)
            await sessionService.start()
            phase = .ready
            diagnostics.activeLens = lenses.first?.displayName ?? "Wide"
        } catch { phase = .failed(error.localizedDescription) }
    }

    func requestCameraAccess() async { guard await permissions.requestCamera() else { phase = .permissionRequired; return }; await prepare() }
    func toggleCamera() async { guard !isTouchLocked else { return }; do { position = try await sessionService.switchCamera(); lenses = try await sessionService.configure(position: position); diagnostics.activeLens = lenses.first?.displayName ?? "—" } catch { phase = .failed(error.localizedDescription) } }
    func chooseLens(_ lens: CameraLens) async { guard !isTouchLocked else { return }; do { try await sessionService.selectLens(lens); diagnostics.activeLens = lens.displayName } catch { phase = .failed(error.localizedDescription) } }
    func focus(at point: CGPoint) async { guard !isTouchLocked else { return }; await sessionService.focusAndExpose(at: point) }

    func toggleRecording() {
        guard mode == .video else { return }
        if isRecording { stopRecording() } else { startRecording() }
    }

    private func startRecording() {
        do { try recordingService.start(segmentDuration: selectedSegmentDuration); phase = .recording; elapsed = 0; protection.beginPreventingAutoLock(); protection.checkStorage(); timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in self?.elapsed += 1 } } catch { phase = .failed(error.localizedDescription) }
    }

    private func stopRecording() {
        timer?.invalidate(); timer = nil
        recordingService.stop { [weak self] result in
            Task { @MainActor in
                self?.protection.endPreventingAutoLock()
                switch result { case .success(let summary): self?.summary = summary; self?.phase = .ready; case .failure(let error): self?.phase = .failed(error.localizedDescription) }
            }
        }
    }

    func dismissSummary() { summary = nil }
    func stopSession() async { if isRecording { stopRecording() }; await sessionService.stop() }
}

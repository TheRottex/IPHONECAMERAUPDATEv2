import SwiftUI

struct CameraScreen: View {
    @ObservedObject var model: CameraViewModel
    @Binding var showsSettings: Bool
    @Binding var showsDiagnostics: Bool

    var body: some View {
        ZStack {
            CameraPreviewView(session: model.sessionService.session) { point in Task { await model.focus(at: point) } }.ignoresSafeArea()
            LinearGradient(colors: [.black.opacity(0.7), .clear, .black.opacity(0.85)], startPoint: .top, endPoint: .bottom).ignoresSafeArea().allowsHitTesting(false)
            VStack {
                header
                Spacer()
                if model.isRecording { RecordingBadge(elapsed: model.elapsed) }
                Spacer()
                controls
            }.padding()
            if model.isTouchLocked { TouchLockOverlay(isLocked: $model.isTouchLocked) }
            if let summary = model.summary { RecordingSummaryView(summary: summary) { model.dismissSummary() } }
            if case .permissionRequired = model.phase { PermissionOverlay { Task { await model.requestCameraAccess() } } }
            if case .failed(let message) = model.phase { MessageOverlay(message: message) { Task { await model.prepare() } } }
            if case .interrupted(let message) = model.phase { MessageOverlay(message: message) { Task { await model.prepare() } } }
        }
    }

    private var header: some View {
        HStack(spacing: 14) {
            Label("\(model.diagnostics.format) \(model.diagnostics.fps)", systemImage: "video")
            Spacer()
            Button { showsDiagnostics = true } label: { Image(systemName: "waveform.path.ecg") }.accessibilityLabel("Tanılama")
            Button { showsSettings = true } label: { Image(systemName: "gearshape") }.accessibilityLabel("Ayarlar")
        }.font(.caption.weight(.semibold)).foregroundStyle(.white).padding(10).background(.black.opacity(0.35), in: Capsule())
    }

    private var controls: some View {
        VStack(spacing: 18) {
            if !model.lenses.isEmpty { HStack(spacing: 18) { ForEach(model.lenses) { lens in Button(lens.zoomLabel) { Task { await model.chooseLens(lens) } }.buttonStyle(.bordered).tint(.white) } } }
            Picker("Mod", selection: $model.mode) { ForEach(CameraMode.allCases) { Text($0.rawValue).tag($0) } }.pickerStyle(.segmented).frame(maxWidth: 190)
            HStack {
                Button { model.isTouchLocked.toggle() } label: { Image(systemName: model.isTouchLocked ? "lock.fill" : "lock.open") }.frame(width: 54, height: 54)
                Spacer()
                Button { model.toggleRecording() } label: { ZStack { Circle().stroke(.white, lineWidth: 5).frame(width: 78, height: 78); Circle().fill(model.isRecording ? .red : .white).frame(width: model.isRecording ? 34 : 62, height: model.isRecording ? 34 : 62).clipShape(RoundedRectangle(cornerRadius: model.isRecording ? 7 : 31)) } }.accessibilityLabel(model.isRecording ? "Kaydı durdur" : "Kaydı başlat")
                Spacer()
                Button { Task { await model.toggleCamera() } } label: { Image(systemName: "arrow.triangle.2.circlepath.camera") }.frame(width: 54, height: 54).accessibilityLabel("Kamerayı değiştir")
            }.font(.title2).foregroundStyle(.white)
        }
    }
}

private struct RecordingBadge: View { let elapsed: TimeInterval; var body: some View { Label("REC  \(elapsed.formatted(.time(pattern: .minuteSecond)))", systemImage: "record.circle.fill").font(.headline.monospacedDigit()).foregroundStyle(.red).padding(10).background(.black.opacity(0.65), in: Capsule()).accessibilityLabel("Kayıt devam ediyor") } }
private struct PermissionOverlay: View { let request: () -> Void; var body: some View { MessageOverlay(message: "Kamera erişimi olmadan önizleme veya kayıt yapılamaz.", button: "Kamera İznini Ver", action: request) } }
private struct MessageOverlay: View { let message: String; var button = "Tekrar Dene"; let action: () -> Void; var body: some View { VStack(spacing: 16) { Image(systemName: "exclamationmark.triangle.fill").font(.largeTitle).foregroundStyle(.yellow); Text(message).multilineTextAlignment(.center); Button(button, action: action).buttonStyle(.borderedProminent) }.padding(28).background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24)).padding() } }
private struct TouchLockOverlay: View { @Binding var isLocked: Bool; @State private var progress = 0.0; var body: some View { Color.black.opacity(0.4).ignoresSafeArea().overlay(VStack(spacing: 12) { Image(systemName: "lock.fill").font(.largeTitle); Text("Dokunmatik kilitli"); Text("Açmak için 3 saniye basılı tutun").font(.caption); ProgressView(value: progress).frame(width: 180) }.foregroundStyle(.white).onLongPressGesture(minimumDuration: 3, pressing: { pressing in withAnimation(.linear(duration: 3)) { progress = pressing ? 1 : 0 } }, perform: { isLocked = false; progress = 0 })) } }

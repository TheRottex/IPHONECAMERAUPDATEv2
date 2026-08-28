import SwiftUI

struct DiagnosticsView: View {
    @ObservedObject var model: CameraViewModel
    @Environment(\.dismiss) private var dismiss
    var body: some View { NavigationStack { List { Section("VORTEX CAMERA") { LabeledContent("Kamera", value: model.diagnostics.activeLens); LabeledContent("Format", value: model.diagnostics.format); LabeledContent("FPS", value: model.diagnostics.fps); LabeledContent("Son hata", value: model.diagnostics.lastError) } Section("Kayıt") { LabeledContent("Durum", value: model.isRecording ? "Kayıt sürüyor" : "Hazır"); LabeledContent("Segment süresi", value: model.selectedSegmentDuration.title) } }.navigationTitle("Tanılama").toolbar { Button("Bitti") { dismiss() } } } }
}

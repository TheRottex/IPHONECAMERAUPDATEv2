import SwiftUI

struct CameraContainerView: View {
    @StateObject private var model = CameraViewModel()
    @State private var showsSettings = false
    @State private var showsDiagnostics = false

    var body: some View {
        CameraScreen(model: model, showsSettings: $showsSettings, showsDiagnostics: $showsDiagnostics)
            .task { await model.prepare() }
            .onDisappear { Task { await model.stopSession() } }
            .sheet(isPresented: $showsSettings) { SettingsView(model: model) }
            .sheet(isPresented: $showsDiagnostics) { DiagnosticsView(model: model) }
    }
}

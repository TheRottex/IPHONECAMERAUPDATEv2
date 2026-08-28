import SwiftUI

struct SettingsView: View {
    @ObservedObject var model: CameraViewModel
    @Environment(\.dismiss) private var dismiss
    var body: some View { NavigationStack { Form { Section("Kayıt") { Picker("Segment süresi", selection: $model.selectedSegmentDuration) { ForEach(SegmentDuration.allCases) { Text($0.title).tag($0) } }; Toggle("Dokunmatik kilit", isOn: $model.isTouchLocked) } Section("Güvenli kullanım") { Text("REC göstergesi video kaydı sırasında her zaman görünür. Uygulama arka planda gizli kayıt yapmaz.").font(.footnote); Text("Uzun kayıtlar için Guided Access’i Ayarlar > Erişilebilirlik menüsünden etkinleştirin.").font(.footnote) } }.navigationTitle("Ayarlar").toolbar { Button("Bitti") { dismiss() } } } }
}

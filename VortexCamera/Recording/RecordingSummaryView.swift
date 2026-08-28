import SwiftUI

struct RecordingSummaryView: View {
    let summary: RecordingSummary
    let dismiss: () -> Void
    var body: some View { VStack(spacing: 18) { Text("Kayıt Tamamlandı").font(.title2.bold()); LabeledContent("Toplam süre", value: summary.totalDuration.formatted(.time(pattern: .minuteSecond))); LabeledContent("Segment", value: "\(summary.segments.count)"); LabeledContent("Dosya boyutu", value: ByteCountFormatter.string(fromByteCount: summary.totalFileSize, countStyle: .file)); Text("Videolar uygulamanın güvenli kayıt klasöründedir. Fotoğraflara aktarma, yalnızca siz seçtiğinizde yapılır.").font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center); Button("Yeni Kayıt", action: dismiss).buttonStyle(.borderedProminent) }.padding(24).background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24)).padding() }
}

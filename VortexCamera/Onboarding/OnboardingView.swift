import SwiftUI

struct OnboardingView: View {
    let finish: () -> Void
    @State private var page = 0
    private let pages = [
        ("Hareket Etse Bile Hedefini Kaybetmeyen Kamera", "VORTEX CAMERA; güvenli kayıt altyapısı ve gelişmiş kamera araçları için hazırlanmış profesyonel bir temel sunar."),
        ("Şeffaf kayıt", "Kayıt, yalnızca siz başlattığınızda yapılır. Video modunda REC göstergesi ve kayıt süresi her zaman görünür."),
        ("İzinler", "Kamera önizleme ve kayıt için kamera; sesli video için mikrofon; seçtiğiniz videoyu dışa aktarmak için Fotoğraflar erişimi gerekir."),
        ("Kayıt koruması", "Uzun kayıtlarda dokunmatik kilidi kullanabilir, videoları güvenli segmentlere ayırabilirsiniz."),
        ("Guided Access", "Yan düğmeyi uygulama devre dışı bırakamaz. Uzun çekimlerde Ayarlar > Erişilebilirlik > Guided Access üzerinden sistemi yapılandırabilirsiniz.")
    ]

    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            Image(systemName: "camera.aperture")
                .font(.system(size: 72, weight: .light))
                .foregroundStyle(.cyan)
            Text(pages[page].0).font(.largeTitle.bold()).multilineTextAlignment(.center)
            Text(pages[page].1).font(.body).foregroundStyle(.secondary).multilineTextAlignment(.center).padding(.horizontal, 30)
            Spacer()
            HStack { ForEach(pages.indices, id: \.self) { index in Capsule().fill(index == page ? .cyan : .gray.opacity(0.4)).frame(width: index == page ? 28 : 8, height: 8) } }
            Button(page == pages.indices.last ? "Kamerayı Aç" : "Devam") { if page == pages.indices.last { finish() } else { withAnimation { page += 1 } } }
                .buttonStyle(.borderedProminent).tint(.cyan).controlSize(.large)
        }.padding()
    }
}

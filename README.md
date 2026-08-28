# Camera (VORTEX CAMERA)

iOS 17+ için SwiftUI ve AVFoundation tabanlı, şeffaf kayıt davranışına sahip kamera uygulaması temeli.

## Kimlik

- Xcode projesi / Swift modülü: `VortexCamera`
- Dahili teknik ad: `VORTEX CAMERA`
- Kullanıcıya görünen ad: `Camera`
- Varsayılan bundle identifier: `com.vortex.camera`

## Bu teslimde

- Onboarding ve açıklamalı kamera izni
- Arka/ön kamera önizlemesi ve cihaz destekli lens seçimi
- Dokunarak odak/pozlama, temel zoom altyapısı
- Açık `REC` göstergeli video kayıt akışı
- 30 sn, 60 sn, 2 dk, 5 dk veya tek dosyalı segmentli kayıt
- Tamamlanmış segment metadata kurtarma altyapısı
- Ekran uyku engeli, pil/depolama/termal uyarı temeli, dokunmatik kilit
- Ayarlar, tanılama, unit/UI test iskeleti ve dokümantasyon

## Mac olmadan ücretsiz derleme (GitHub Actions)

GitHub Actions workflow’u, GitHub’ın macOS runner’ında imzasız **iOS Simulator** build’i üretir. Bu build Swift/Xcode hatalarını kontrol etmek içindir; fiziksel iPhone’a yüklenebilen IPA değildir.

1. Projeyi GitHub’daki private repository’nize yükleyin.
2. **Actions > iOS Build > Run workflow** çalıştırın.
3. İş bitince `Camera-simulator-app` artifact’ini indirin.

Ayrıntılar ve kota/imzalama sınırları: [GitHub build rehberi](Docs/GITHUB_BUILD.md).

## macOS’ta fiziksel cihaz ve IPA derleme

Bu depo Windows’ta hazırlanmıştır; iPhone’a kurulabilen imzalı IPA üretimi için macOS ve Xcode gerekir.

1. Xcode 15+ ile `VortexCamera.xcodeproj` açın.
2. Signing & Capabilities altında kendi Apple Developer Team’inizi seçin; `com.vortex.camera` benzersiz değilse değiştirin.
3. Target’ın iOS 17.0 olduğundan ve `Info.plist` dosyasının hedefe bağlı olduğundan emin olun.
4. `Assets.xcassets` içindeki özgün lens simgesini isterseniz kendi marka simgenizle değiştirin.
5. Fiziksel iPhone’da kamera/mikrofon/Fotoğraflar izinlerini test edin.
6. TestFlight/IPA için Release scheme ile Product > Archive kullanın.

> Simulator gerçek kamera davranışını temsil etmez. Segmentli kayıt, kesinti kurtarma ve lens yetenekleri fiziksel cihazda doğrulanmalıdır.

Daha fazla bilgi: [Docs](Docs/).

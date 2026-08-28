# Ücretsiz GitHub ile iOS derleme

Mac bilgisayar olmadan GitHub Actions’ın macOS runner’larında **imzasız Simulator build** alabilirsiniz. Bu, Swift/Xcode proje hatalarını erken yakalamak ve `.app` artifact indirmek için uygundur.

## Önemli sınırlar

- GitHub artifact’i **Simulator için `Camera.app`** içerir. iPhone’a kurulamaz.
- Fiziksel cihazda açılan `.ipa`, Apple code signing, bir Apple Developer Team ve provisioning profile gerektirir.
- TestFlight veya App Store’a yükleme için Apple Developer Program üyeliği gerekir.
- GitHub-hosted macOS runner dakikaları ücretsiz hesaplarda sınırlıdır; kota GitHub planınıza göre değişir. Çalıştırmadan önce GitHub Billing > Plans and usage bölümünü kontrol edin.
- Kamera, mikrofon, gerçek lensler, depolama uyarıları ve segment kurtarma Simulator’da tam doğrulanamaz.

## Kurulum

1. Bu klasörü kendi GitHub hesabınızda **private repository** olarak oluşturun ve yükleyin.
2. Varsayılan dalı `main` yapın veya workflow’daki `branches: [main]` değerini kendi dalınıza göre değiştirin.
3. GitHub’da **Actions** sekmesine girin.
4. `iOS Build` workflow’unu seçip **Run workflow** çalıştırın veya `main` dalına bir commit gönderin.
5. İş bitince Actions run altındaki **Artifacts** bölümünden `Camera-simulator-app` dosyasını indirin.

## İş akışının yaptığı işlem

[`.github/workflows/ios-build.yml`](../.github/workflows/ios-build.yml), GitHub’ın `macos-14` runner’ında aşağıdakini çalıştırır:

```bash
xcodebuild \
  -project VortexCamera.xcodeproj \
  -target VortexCamera \
  -configuration Debug \
  -sdk iphonesimulator \
  CODE_SIGNING_ALLOWED=NO \
  build
```

Ardından ortaya çıkan `Camera.app` dosyasını zipleyip 7 gün saklanan workflow artifact’i olarak yükler.

## İleride gerçek iPhone IPA’sı

Bir Mac veya uygun bir cloud-mac erişimi olduğunda:

1. Apple Developer Team’inizi Xcode Signing & Capabilities ekranında seçin.
2. `com.vortex.camera` benzersiz değilse kendi bundle identifier’ınızla değiştirin.
3. Fiziksel iPhone’da izinleri, kayıt kesintilerini ve segment kurtarmayı test edin.
4. Xcode’dan **Product > Archive** çalıştırıp Organizer ile TestFlight’a yükleyin.

İmzalama sertifikalarını veya provisioning profile dosyalarını GitHub repository’ye kesinlikle eklemeyin. CI ile imzalı dağıtım kurmak isterseniz, yalnızca private repository’de GitHub Actions Secrets kullanın.

# Bilinen teknik sınırlar

- Bu Windows ortamında Xcode build, iOS simulator, imzalama veya IPA doğrulaması yapılamaz.
- `AppIcon` kataloğu teknik yer tutucudur; macOS’ta özgün tasarım dosyaları eklenmelidir.
- AVAssetWriter çözünürlük/codec ayarları ilk sürümde H.264 1080p varsayılanıdır. Cihaza özgü 4K/FPS format seçimi sonraki doğrulama adımıdır.
- App Store dağıtımı için gerçek Apple Developer Team, benzersiz bundle ID, signing ve privacy metadata gerekir.
- Vision takip, Core Motion stabilizasyonu, gelişmiş temalar ve fotoğraf çekimi bu Aşama 1–3 temeline henüz eklenmemiştir.

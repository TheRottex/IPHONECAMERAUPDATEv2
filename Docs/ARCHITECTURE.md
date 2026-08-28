# Mimari

Uygulama SwiftUI görünümünü AVFoundation donanım işlemlerinden ayırır.

- `CameraViewModel`: `@MainActor` UI state ve kullanıcı eylemleri.
- `CameraSessionService`: `AVCaptureSession` yapılandırmasını özel seri kuyrukta çalıştırır.
- `SegmentedRecordingService`: video/audio sample buffer’larını `AVAssetWriter` ile segmentlere yazar.
- `MediaStorageService`: tamamlanmış segment metadata’sını Application Support altında atomik saklar.
- `RecordingProtectionService`: ekran uykusu, pil, depolama ve termal uyarı temelini yönetir.
- `PhotoLibraryWriter`: yalnızca açık kullanıcı eylemi sonrası Photos aktarımı için adapter’dır.

## Sonraki aşamalar

Motion/ufuk kilidi, Vision hedef takibi, güçlü sabitleme, Metal render ve tema sistemi; temel kayıt fiziksel cihazlarda kararlı doğrulandıktan sonra ayrı modüller olarak eklenmelidir.

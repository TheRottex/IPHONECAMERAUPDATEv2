# Test planı

## Otomatik

- Kamera izni: ilk istek, ret, yeniden hazırlama
- Kamera state geçişleri ve servis hataları
- Segment süre seçimi, segment metadata kaydı, eksik dosya kurtarmasının elenmesi
- Kayıt arayüzünde REC/süre/durdurma erişilebilirliği

## Fiziksel cihaz

1. Ön/arka kamera ve cihazdaki mevcut lensler.
2. Mikrofon izni reddedilmiş sessiz video.
3. Düşük depolama, %20/%10 pil, serious/critical termal durum.
4. Arka plan/foreground, telefon araması ve AVCaptureSession interruption.
5. 60 saniyelik segment dönüşümü ve beklenmedik kapanma sonrası önceki segmentlerin varlığı.
6. Guided Access açık/kapalı ve dokunmatik kilidin üç saniye basılı tutmayla açılması.
7. 4K/60 FPS/lens desteği olmayan cihazlarda yalnızca desteklenen seçeneklerin gösterilmesi.

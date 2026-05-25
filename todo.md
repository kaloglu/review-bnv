# Todo

Aşağıdaki maddeler proje içinde tespit edilen notlar doğrultusunda oluşturulmuştur. Her madde ilgili BNV-#### kimliğiyle Issues.md içinde açıklanmıştır.

- [x] BNV-0001 — Dokümantasyon uyumu: AGENTS.md içindeki constants dizin yolu proje yapısıyla hizalansın (Ek Not eklendi)
- [ ] BNV-0002 — Dosya adı düzeltme: `lib/Presentation/providers/ad_reward_profile screen.dart` dosyasını `ad_reward_profile_screen.dart` olarak yeniden adlandır ve importları güncelle
- [ ] BNV-0003 — İsimlendirme standardizasyonu: `buttonEndDate.dart` ve `reward_Ad.dart` dosyalarını snake_case ile yeniden adlandır ve tüm importları güncelle
- [ ] BNV-0004 — Yazım hatası: `tagsProvder.dart` dosyasını `tags_provider.dart` olarak yeniden adlandır ve importları güncelle
- [ ] BNV-0005 — Local Run: Java/Gradle uyumsuzluğu (JDK 21 vs Gradle 7.5). Geçici çözüm: Java 17 ile çalıştır. Alternatif: Gradle/AGP yükseltmesi (onay bekliyor)
- [ ] BNV-0006 — (Opsiyon) Gradle wrapper ve AGP yükseltme planını hazırla (Java 21 uyumlu sürümlere geçiş); etki analizi ve geri alma planı hazırla
- [x] BNV-0007 — Android settings.gradle: Flutter plugin loader düzeltmesi (flutter-plugin-loader)
- [x] BNV-0008 — AndroidManifest: Activity tam sınıf adını `com.example.cihan_app.MainActivity` ile hizala
- [x] BNV-0009 — Android SDK 35’e yükselt: `compileSdkVersion` ve `targetSdkVersion` 35 yap
- [x] BNV-0010 — Geçici çözüm: namespace eksik kütüphanelere otomatik namespace ataması ekle (kök build.gradle)
- [ ] BNV-0011 — Kalıcı çözüm: `flutter_keyboard_visibility` dâhil transitif plugin’leri AGP 8 uyumlu sürümlere yükselt; ardından geçici namespace bloğunu kaldır

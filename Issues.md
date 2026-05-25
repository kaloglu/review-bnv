# Issues

Bu dosya, todo.md içindeki BNV kimliklerinin kapsamını, nedenini ve kabul kriterlerini açıklar.

---

## BNV-0001 — Dokümantasyon uyumu: constants yolu
- Kapsam: AGENTS.md içinde geçen `lib/constants/` ifadesi proje yapısında `lib/Presentation/constants/` olduğundan dokümantasyon notu eklenmesi.
- Neden: Geliştiricilerin yanlış dizine yönelmesini önlemek ve import tutarlılığını korumak.
- Çözüm: AGENTS.md'ye "Ek Not" eklendi ve doğru yol belirtildi.
- Kabul Kriterleri:
  - [x] AGENTS.md içinde açık bir ek notla doğru yol belirtilmiş olmalı.

## BNV-0002 — Dosya adı düzeltme: ad_reward_profile screen.dart
- Kapsam: `lib/Presentation/providers/ad_reward_profile screen.dart` dosya adındaki boşluğun kaldırılması ve `ad_reward_profile_screen.dart` olarak güncellenmesi.
- Neden: Boşluk içeren dosya adları import hatalarına ve platformlar arası sorunlara yol açar.
- Çözüm Adımları:
  1. Dosyayı `ad_reward_profile_screen.dart` olarak yeniden adlandır.
  2. Bu dosyayı import eden tüm yerlerde yeni ada güncelleme yap.
  3. Derleme hatası kalmadığını doğrula.
- Kabul Kriterleri:
  - [ ] Projede boşluk içeren dosya adı kalmamalı.
  - [ ] Derleme başarılı olmalı; import hatası olmamalı.

## BNV-0003 — İsimlendirme standardizasyonu: buttonEndDate.dart ve reward_Ad.dart
- Kapsam: `buttonEndDate.dart` ve `reward_Ad.dart` dosyalarını snake_case (ör. `button_end_date.dart`, `reward_ad.dart`) standardına getirmek ve tüm importları güncellemek.
- Neden: Platformlar arası dosya sistemi ve import tutarlılığı, okunabilirlik ve stil kılavuzuna uyum.
- Çözüm Adımları:
  1. Dosya adlarını snake_case'e çevir.
  2. Tüm ilgili importları güncelle.
  3. Derlemeyi doğrula.
- Kabul Kriterleri:
  - [ ] İlgili dosyalar snake_case formatında olmalı.
  - [ ] Derleme hatası olmamalı; importlar güncellenmiş olmalı.

## BNV-0004 — Yazım hatası: tagsProvder.dart
- Kapsam: `lib/Presentation/providers/tagsProvder.dart` dosya adındaki yazım hatasının `tags_provider.dart` olarak düzeltilmesi ve importların güncellenmesi.
- Neden: Yazım hataları IDE araması, otomatik tamamlama ve ekip standardizasyonunu olumsuz etkiler.
- Çözüm Adımları:
  1. Dosyayı `tags_provider.dart` olarak yeniden adlandır.
  2. Tüm import referanslarını güncelle.
  3. Derlemeyi doğrula.
- Kabul Kriterleri:
  - [ ] Dosya adı yazım hatasından arındırılmış olmalı.
  - [ ] Derleme hatası olmamalı; importlar güncellenmiş olmalı.

---

## BNV-0005 — Local Run: Java/Gradle uyumsuzluğu (JDK 21 vs Gradle 7.5)
- Kapsam: Dreamflow Local Run sırasında "Unsupported class file major version 65" hatası. Bu, yerelde Java 21 (classfile 65) ile Gradle 7.5 çalıştırılmasından kaynaklanır.
- Neden: Projede `android/gradle/wrapper/gradle-wrapper.properties` Gradle 7.5'i işaret ediyor. Gradle 7.5, Java 21 ile çalıştırılmayı desteklemez.
- Çözüm Seçenekleri:
  1) Hızlı ve düşük risk: Yerelde Java 17 ile çalıştır (JAVA_HOME/Gradle JDK'yi 17'ye sabitle).
  2) Alternatif: Gradle/AGP yükselt (Java 21 ile uyumlu sürümlere geç). Etki analizi gerekir.
- Kabul Kriterleri:
  - [ ] Local Run ile `flutter run` sorunsuz tamamlanır, derleme hatası alınmaz.
  - [ ] Seçilen çözüm ve uygulanan adımlar bu dosyaya not düşülür.

## BNV-0006 — (Opsiyon) Gradle wrapper ve AGP yükseltme planı (Java 21 uyum)
- Kapsam: Gradle 8.5+ ve uyumlu Android Gradle Plugin sürümüne geçiş; Kotlin sürümünün eşgüdümü; gerekli Gradle/AGP betik değişiklikleri.
- Neden: Yerelde Java 21 kullanmak istendiğinde Gradle 7.x/AGP 7.x zinciri uyumsuzdur.
- Çözüm Adımları (onay sonrası):
  1. Gradle wrapper'ı 8.5+ sürümüne güncelle.
  2. AGP'yi 8.x uyumlu sürüme çıkar; Kotlin sürümünü matris uyarınca hizala.
  3. Gerekirse `settings.gradle`/`build.gradle` DSL farklarını uygula, `compileSdk`/`targetSdk` değerlerini doğrula.
  4. Temiz derleme alındığını doğrula.
- Kabul Kriterleri:
  - [ ] `./gradlew -v` çıktısı Java 21 ile çalışan Gradle 8.5+ gösterir.
  - [ ] `flutter build apk` ve `flutter run` başarılıdır.
  - [ ] Uygulama çalışma zamanı davranışında geriye dönük bozulma tespit edilmez.

---

## BNV-0007 — Android settings.gradle: Flutter plugin loader düzeltmesi
- Kapsam: `settings.gradle` içinde `dev.flutter.flutter-gradle-plugin` yerine `dev.flutter.flutter-plugin-loader` tanımlanmalı.
- Neden: Yanlış loader tanımı, Flutter Android embed kütüphanelerinin derleme sınıf yoluna eklenmesini engelleyip `Unresolved reference: flutter` hatasına yol açar.
- Çözüm Adımları:
  1. `plugins` bloğunda `dev.flutter.flutter-plugin-loader` eklentisini uygula.
  2. `dev.flutter.flutter-gradle-plugin` tanımını `apply false` olarak kaldır.
  3. Temiz derleme al.
- Kabul Kriterleri:
  - [ ] Kotlin derlemesi sırasında `io.flutter.embedding.android.FlutterActivity` çözümlenebilmeli.
  - [ ] `assembleDebug` hatasız tamamlanmalı.

## BNV-0008 — AndroidManifest: Activity tam sınıf adı uyumu
- Kapsam: Manifest’te `android:name=".MainActivity"` yerine tam nitelikli `com.example.cihan_app.MainActivity` kullanımı.
- Neden: `applicationId` ile Activity sınıf paket adı farklı olduğunda kısaltılmış ad yanlış sınıfa çözümlenebilir.
- Çözüm Adımları:
  1. Manifest’te Activity adını tam nitelikli sınıf adıyla güncelle.
  2. Uygulama başarıyla başlatılabilmeli.
- Kabul Kriterleri:
  - [ ] Uygulama açılış Activity’si doğru sınıfa işaret eder.
  - [ ] Çalışma zamanı çakışması/ActivityNotFound hatası görülmez.

# Issues — BNV Kimlikleri ve Açıklamalar

Aşağıda todo.md dosyasındaki BNV-#### kimliklerinin kapsamı, nedenleri ve kabul kriterleri özetlenmiştir.

---
## BNV-0001 — Firebase başlatma ve firebase_options.dart varlığı
- Durum: Tamamlandı
- Neden: Uygulamanın Firebase kaynaklarına erişebilmesi için zorunlu başlangıç.
- Kapsam: `main.dart` içinde `Firebase.initializeApp(... DefaultFirebaseOptions.currentPlatform)` çağrısı; `lib/firebase_options.dart` mevcut.
- Kabul Kriterleri:
  - Uygulama açılışında Firebase hata vermez.
  - `firebase_options.dart` projede bulunur ve platforma uygun yapılandırmayı içerir.

## BNV-0002 — ProviderScope + OverlaySupport
- Durum: Tamamlandı
- Neden: Riverpod ve bildirim/overlay altyapısı için gerekli kök sarmalayıcılar.
- Kapsam: `runApp(const ProviderScope(child: MyApp()))` ve `OverlaySupport.global` kullanımı.
- Kabul Kriterleri:
  - Riverpod provider'ları sorunsuz çalışır.
  - Overlay bildirimleri (overlay_support) görüntülenebilir.

## BNV-0003 — FirebaseUI kimlik sağlayıcıları
- Durum: Tamamlandı
- Neden: Giriş/üye olma akışlarının hazır olması.
- Kapsam: `FirebaseUIAuth.configureProviders([...])` ile Google, Facebook, Twitter, Phone tanımlı.
- Risk/Not: Google/Facebook/Twitter için OAuth Client ID ve redirect URI’ların Firebase panelinde doğrulanması gerekir (bkz: BNV-0008).
- Kabul Kriterleri:
  - Sağlayıcılar SignInScreen’de listelenir.

## BNV-0004 — Android AdMob App ID manifest
- Durum: Tamamlandı
- Neden: Google Mobile Ads SDK’nın başlatılması için gerekli.
- Kapsam: AndroidManifest.xml içinde `com.google.android.gms.ads.APPLICATION_ID` meta-data mevcut.
- Kabul Kriterleri:
  - Reklam SDK başlangıcı hata vermez.

## BNV-0005 — Assets tanımları
- Durum: Tamamlandı
- Neden: Görsellerin ve ikonların yüklenmesi için gerekli.
- Kapsam: `pubspec.yaml` altında `assets/images/` ve diğer tekil varlıklar tanımlı.
- Kabul Kriterleri:
  - Varlıklar uygulamada görüntülenir, load hatası oluşmaz.

## BNV-0006 — Import/kasa tutarlılığı (AuthGate ve ekranlar)
- Durum: Bekliyor
- Neden: Linux/Web gibi kasa duyarlı ortamlarda derleme hatalarını önlemek.
- Kapsam: `lib/Data/services/auth_gate.dart` içinde `package:cihan_app/presentation/...` importları, gerçek klasör adı `Presentation/` ile uyumsuz. Tüm importlar `package:cihan_app/Presentation/...` şeklinde normalize edilecek; relative importlar mümkünse kaldırılacak.
- Kabul Kriterleri:
  - `flutter analyze` kasa/konum kaynaklı import hatası vermez.
  - CI/derleme ortamında platform farkı olmadan çalışır.

## BNV-0007 — Firebase Messaging background handler iyileştirmesi
- Durum: Bekliyor
- Neden: Android’de arka plan mesaj işleyicisinin kesilmesini önlemek; foreground/onMessageOpenedApp olaylarını ele almak.
- Kapsam: Background fonksiyonuna `@pragma('vm:entry-point')` eklenmesi; `FirebaseMessaging.onMessage` ve `onMessageOpenedApp` dinleyicilerinin kurulması; iOS izin akışının doğrulanması.
- Kabul Kriterleri:
  - Uygulama kapalı/arka plandayken gelen iletiler işlenir.
  - Foreground bildirimleri kullanıcıya gösterilir veya uygun şekilde işlenir.

## BNV-0008 — Web OAuth yapılandırması
- Durum: Bekliyor
- Neden: Web oturum açma akışlarının başarılı olması için zorunlu Firebase Console ayarları.
- Kapsam: Authorized domains liste kontrolü; Google/Facebook/Twitter için uygun Client ID ve redirect URL’leri.
- Kabul Kriterleri:
  - Web’de Google/Facebook/Twitter ile sorunsuz giriş yapılır.

## BNV-0009 — Dosya adı düzeltmesi (ad_reward_profile screen.dart)
- Durum: Bekliyor
- Neden: Dosya adında boşluk, import ve araç zinciri sorunlarına neden olabilir.
- Kapsam: Dosya adının `ad_reward_profile_screen.dart` olarak değiştirilmesi ve bütün referansların güncellenmesi.
- Kabul Kriterleri:
  - Dosya sisteminde ve tüm importlarda yeni ad kullanılır; derleme hatası oluşmaz.

## BNV-0010 — İmla düzeltmesi (tagsProvder.dart)
- Durum: Bekliyor
- Neden: Yazım hataları bakım ve keşfi zorlaştırır; olası çakışmalara yol açar.
- Kapsam: `tagsProvder.dart` → `tags_provider.dart` olarak yeniden adlandırma; import güncellemeleri.
- Kabul Kriterleri:
  - Tüm importlar yeni dosya adına işaret eder; analyzer hatası yoktur.

## BNV-0011 — Shimmer bileşenlerini konsolide etme
- Durum: Bekliyor
- Neden: `Presentation/constants/shimmer_effect.dart` ve `Presentation/utils/shimmer_effect.dart` arasında tekrar ve olası çakışmalar.
- Kapsam: Tek bir shimmer yardımcı bileşen dosyası altında toplayıp diğer referansları güncellemek.
- Kabul Kriterleri:
  - Shimmer ile ilgili importlar tek bir kaynağa işaret eder; UI değişmeden çalışır.

## BNV-0012 — Secrets yönetimi (Keys)
- Durum: Bekliyor
- Neden: Kaynakta gizli anahtar bulundurmamak, ortam bazlı yönetim sağlamak.
- Kapsam: `lib/Data/services/secrete_keys.dart` içindeki sabitlerin Dreamflow/Firebase tarafına taşınması; kaynak kodda maskelenmesi/kaldırılması.
- Kabul Kriterleri:
  - Kaynakta gizli değer kalmaz; uygulama çalışırken doğru değerleri ortamdan alır.

## BNV-0013 — Firestore şema ve örnek veri
- Durum: Bekliyor
- Neden: Uygulamanın ekranlarının veri göstermesi için asgari örnek belgeler gerekir.
- Kapsam: `users`, `raffles`, `enrollments`, `tickets` koleksiyonları; en az bir `raffles` belgesi ve gerekli alanlar.
- Kabul Kriterleri:
  - Home/Detay ekranlarında veri görüntülenir; hata/log oluşmaz.

## BNV-0014 — Branch.io entegrasyonu
- Durum: Bekliyor
- Neden: Derin bağlar ve paylaşımdan dönüş akışlarını yönetebilmek.
- Kapsam: SDK init ve dinleme (istenirse); ya da tüm Branch yapılandırmalarını devre dışı bırakma.
- Kabul Kriterleri:
  - Derin linkten açılışta beklenen rota çalışır ya da özelliğin kapalı olduğu net biçimde loglanır.

## BNV-0015 — iOS Reklam ve izin metinleri
- Durum: Bekliyor
- Neden: App Store gereksinimleri ve reklam ağları için zorunlu plist girişleri.
- Kapsam: Info.plist’e SKAdNetwork kimlikleri ve `NSUserTrackingUsageDescription` eklenmesi.
- Kabul Kriterleri:
  - iOS derlemesinde izin/gizlilik uyarıları doğru görünür; mağaza gereksinimleri karşılanır.

## BNV-0016 — Kod stili ve provider ömrü
- Durum: Bekliyor
- Neden: Tutarlı importlar, daha okunabilir kod ve sızıntıların önlenmesi.
- Kapsam: Tüm importların `package:cihan_app/...` standardına çekilmesi; relative importların temizlenmesi; UI’ya bağlı provider’larda `autoDispose` gözden geçirme.
- Kabul Kriterleri:
  - Analyzer uyarıları azalır/sıfırlanır; gereksiz bellek tutulumları önlenir.

## BNV-0017 — CI/Analiz ve derleme uyarıları
- Durum: Bekliyor
- Neden: Sürekli entegrasyonda sorunsuz derleme ve kalite ölçümü.
- Kapsam: `flutter analyze` ve derleme çıktılarındaki uyarı/hataların giderilmesi, temel run konfigürasyonlarının kontrolü.
- Kabul Kriterleri:
  - Analiz çıktısı kritik hata içermez; uygulama tüm hedeflerde derlenir.

---
Notlar:
- Firebase bağlantısı Dreamflow içindeki Firebase panelinden yönetilir. CLI/harici kurulum yapılmamalıdır.
- Secrets için yeni değerler kaynakta sabit olarak eklenmemelidir; mümkünse yönetilen yapılandırmalar veya çalışma zamanı değişkenleri tercih edilmelidir.

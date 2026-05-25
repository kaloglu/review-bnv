# Issues — BNV Haritası ve Kabul Kriterleri

Her BNV maddesi için kapsam, neden ve kabul kriterleri aşağıdadır.

---
## BNV-0001 — Flutter bağımlılıkları çözümlendi ve uygulama derleniyor/çalışıyor
- Açıklama: `flutter pub get` sonrası uygulama ayağa kalkıyor. Önizlemede render alınıyor.
- Neden: Geliştirmeye başlayabilmek için temel derleme/çalıştırma stabil olmalı.
- Kabul Kriterleri:
  - Önizlemede ana ağaç render edilir (MaterialApp görünür).
  - Derleme aşamasında bloklayıcı hata yok.
- Durum: Tamamlandı

## BNV-0002 — Firebase başlatma (firebase_options.dart) uygulama açılışında sorunsuz
- Açıklama: Firebase Core `main.dart` içinde başlatılır, hatasız tamamlanır.
- Neden: Auth, Firestore ve Messaging çalışması için gerekli.
- Kabul Kriterleri:
  - Başlangıçta Firebase init hatası loglarda yok.
  - FirebaseUI SignInScreen yüklenebiliyor.
- Durum: Tamamlandı

## BNV-0003 — Kimliksiz akışta FirebaseUI SignInScreen görüntüleniyor (AuthGate çalışıyor)
- Açıklama: AuthState unauthenticated iken SignInScreen sunulur.
- Neden: Kullanıcı girişine giden temel akış.
- Kabul Kriterleri:
  - Widget ağacında `SignInScreen` görünüyor.
  - Giriş seçenekleri ekranda.
- Durum: Tamamlandı

## BNV-0004 — Kimlik doğrulama sonrası HomeScreen'e yönlendirme sorunsuz
- Açıklama: Başarılı girişten sonra kullanıcı HomeScreen'e alınır.
- Neden: Ana kullanım akışına geçiş.
- Kabul Kriterleri:
  - Test hesabı ile giriş sonrası HomeScreen render edilir.
  - Geri dönüş (logout) akışı da çalışır.
- Durum: Bekliyor (manuel doğrulama gerekli)

## BNV-0005 — Firestore sorguları/stream'leri erişilebilir ve hata vermiyor
- Açıklama: Home ve detay sayfalarındaki Firestore stream'leri veri/boş durumları düzgün yönetir.
- Neden: Listeleme, ayrıntı ve geçmiş sayfaları için kritik.
- Kabul Kriterleri:
  - StreamBuilder/Provider tarafında hata state'i görülmez.
  - Boş veri ve dolu veri durumları sorunsuz render edilir.
- Durum: Bekliyor (bağlı koleksiyonlarda veri kontrolü gerekli)

## BNV-0006 — RewardedInterstitialAd kurulumunda çökme yok, temel akış çalışıyor
- Açıklama: Ödüllü reklam yükleme/gösterme akışında crash veya takılma olmaz.
- Neden: Bilet kazanma akışı için gereklidir.
- Kabul Kriterleri:
  - Reklam yüklenir, gösterilir, `onUserEarnedReward` tetiklenir.
  - Hata durumları log'lanır ve UI kilitlenmez.
- Durum: Bekliyor (cihaz/emülatör testi gerekebilir)

## BNV-0007 — Bildirim izinleri ve background handler kaydı problemsiz
- Açıklama: `firebase_messaging` izin isteği, token alma ve background handler kaydı hatasız.
- Neden: Kazanan/duyuru bilgilendirmeleri için gerekli.
- Kabul Kriterleri:
  - Token alınır ve log'lanır.
  - Background mesaj geldiğinde handler çalışır (log izlenir).
- Durum: Bekliyor

## BNV-0008 — Web önizlemede CanvasKit ile sayfalar açılıyor
- Açıklama: Dreamflow web önizlemede sayfalar sorunsuz render edilir.
- Neden: Geliştirme döngüsünde hızlı geri bildirim için kritik.
- Kabul Kriterleri:
  - Önizlemede AuthGate ve SignInScreen görülür.
  - Navigasyon hataları yaşanmaz.
- Durum: Tamamlandı

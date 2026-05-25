# BedavaNevar — Çalıştırma Kontrol Listesi (TODO)

Bu liste uygulamanın hatasız şekilde ayağa kalkması için gereken adımları içerir. Her madde benzersiz bir BNV-#### kimliği ile takip edilir ve Issues.md dosyasında detayları yer alır.

Durum simgeleri:
- [x] Tamamlandı
- [ ] Bekliyor

## Başlangıç ve Kurulum
- [x] BNV-0001 — Firebase başlatma ve firebase_options.dart dosyasının varlığı doğrulandı
- [x] BNV-0002 — Riverpod ProviderScope + OverlaySupport kurulumu doğrulandı
- [x] BNV-0003 — FirebaseUI kimlik sağlayıcıları (Google, Facebook, Twitter, Phone) tanımlandı
- [x] BNV-0004 — Android AdMob App ID, AndroidManifest.xml içine tanımlı
- [x] BNV-0005 — Varlıklar (assets/) pubspec.yaml altında tanımlı ve erişilebilir

## Kimlik Doğrulama ve Navigasyon
- [ ] BNV-0006 — Import ve klasör isimlerinde büyük/küçük harf tutarlılığı (AuthGate ve ekran importları normalizasyonu)
- [ ] BNV-0008 — Web OAuth yapılandırması: Firebase panelinde OAuth Client ID ve Authorized Domains kontrolü

## Bildirimler (Firebase Messaging)
- [ ] BNV-0007 — Background mesaj işleyicisini @pragma('vm:entry-point') ile işaretleme, foreground/onMessageOpenedApp dinleyicileri ekleme; iOS izin akışını doğrulama

## Reklamlar (Google Mobile Ads)
- [ ] BNV-0015 — iOS tarafı Info.plist güncellemeleri (SKAdNetwork IDs, NSUserTrackingUsageDescription)

## Kod Hijyeni ve Adlandırma
- [ ] BNV-0009 — Dosya adı düzeltmesi: "ad_reward_profile screen.dart" → "ad_reward_profile_screen.dart" ve ilgili importların güncellenmesi
- [ ] BNV-0010 — İmla düzeltmesi: "tagsProvder.dart" → "tags_provider.dart" ve referansların güncellenmesi
- [ ] BNV-0011 — Shimmer bileşenlerinin çift tanımlarını birleştirme (constants vs utils)
- [ ] BNV-0016 — Kod stili: Tüm importları package:cihan_app/... standardına çekme; relative importları temizleme; Riverpod autoDispose kullanım kontrolleri

## Veritabanı ve Örnek Veriler
- [ ] BNV-0013 — Firestore koleksiyon şeması doğrulama ve örnek verilerin eklenmesi: users, raffles, enrollments, tickets (en az bir örnek raffle)

## Derin Bağlantılar ve Bağlantılı Servisler
- [ ] BNV-0014 — Branch.io entegrasyonunun tamamlanması (init, link dinleme) ya da kontrollü şekilde devre dışı bırakılması

## Güvenlik ve Sırlar
- [ ] BNV-0012 — Secrets yönetimi: Keys sınıfındaki sabitlerin Dreamflow/Firebase yönetimine taşınması; kaynak koddan temizlenmesi

## CI/Analiz
- [ ] BNV-0017 — flutter analyze / derleme uyarılarının giderilmesi; temel run konfigürasyonlarının gözden geçirilmesi


Notlar:
- Firebase bağlantısı Dreamflow içindeki Firebase panelinden yönetilir. CLI ile kurulum yapılmaz.
- Her tamamlanan madde, Issues.md'deki kabul kriterlerine göre doğrulanmalıdır.

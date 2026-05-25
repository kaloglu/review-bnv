# AGENTS.md

> ⚠️ **ÖNEMLİ KURAL — DİL:**
> Bu projede çalışan tüm AI ajanları (Hologram / Dreamflow Agent dahil) kullanıcıya **TÜM cevapları MUTLAKA Türkçe** olarak vermelidir.
> Kod içi değişken adları, sınıf adları ve teknik terimler İngilizce kalabilir; ancak **açıklamalar, özetler, hata mesajları, sorular ve yönlendirmeler Türkçe** olmalıdır.

---

## 1. Proje Özeti

**Proje Adı:** BnV — Ücretsiz Çekiliş Uygulaması

**Tek Cümleyle:** Kullanıcıların ücretsiz olarak katılabileceği günlük çekilişlerin düzenlendiği, kazananlara ürünlerin ücretsiz kargo ile gönderildiği bir mobil uygulamadır.

### 1.1. Konsept

- Uygulama sahibi (yayıncı), **sıfır veya ikinci el ürünleri, yiyecekleri, araçları** veya benzeri herhangi bir şeyi çekiliş olarak yayına alır.
- Belirlenen şartlar tamamlandığında, talep eden katılımcılar arasından seçilen kişi(ler)e ürün **ücretsiz kargo** ile gönderilir.
- Katılımcılardan **hiçbir ücret talep edilmez**. Uygulama tamamen ücretsizdir.

### 1.2. Katılım Hakkı Sistemi

- **Günlük Ücretsiz Hak:** Her kullanıcıya **her gün saat 09:00**'da otomatik olarak **1 (bir) katılım hakkı** tanımlanır.
- **Ek Haklar (Görevlerle Kazanılır):** Kullanıcılar ek katılım hakları kazanmak için çeşitli görevleri tamamlayabilir. Görevler ve ödüller dinamik olarak değişebilir. Örnekler (sadece örnektir, değişebilir):
  - 🎬 **Reklam İzleme:** Bir reklam izlenerek **+3 katılım hakkı** kazanılır.
  - 📱 **Sosyal Medya Paylaşımı:** Twitter / Instagram'da uygulamadan bahseden bir paylaşım yapılarak **+5 katılım hakkı** kazanılır.
  - 👥 **Arkadaş Davet Etme:** Davet edilen arkadaş uygulamaya katıldığında davet edene **+10 katılım hakkı** verilir.
- Görev sayısı, türü ve ödül miktarları **yapılandırılabilir** olmalıdır (hard-coded olmamalıdır).

---

## 2. Çalışan Ajanlar İçin Kritik Kurallar

### 2.1. Bozma! (Do Not Break!)

> 🛑 **Bu proje mevcut haliyle çalışır durumdadır. Çalışan kodu BOZMADAN devam ettir.**

- Mevcut dosya yapısını, mimari kararları ve isimlendirme kurallarını **koru**.
- Refactor önerilerini **kullanıcı açıkça istemedikçe yapma**.
- Var olan dosyaları silmeden / taşımadan önce **kullanıcıya sor**.
- Dependency (paket) sürümlerini kullanıcı istemeden güncelleme. Mevcut `pubspec.yaml` eski paket sürümleri içerebilir; bunlara dokunmadan önce kullanıcıya bilgi ver.

### 2.2. Cevap Dili

- ✅ **Türkçe** açıklama yap.
- ✅ Hata mesajlarını, log çıktılarını ve özet metinleri Türkçe yaz (kullanıcıya yönelik olanlar).
- ❌ İngilizce uzun açıklama **yazma**.
- 💬 Teknik kod / sınıf / değişken adları İngilizce kalabilir (Flutter ekosistem standardı).

### 2.3. Görev Tamamlama

- Yapılan değişikliklerden sonra `compile_project` aracı ile hata kontrolü yap.
- Değişiklik özetini **2–4 kısa Türkçe cümle** ile aktar; dosya dosya detay verme.

---

## 5. Eklenmesi Planlanan / Gelecek Özellikler

Aşağıdaki özellikler henüz tamamlanmamış olabilir; geliştirme yaparken bu yol haritasını dikkate al:

- [ ] **Günlük 09:00 ücretsiz hak otomatik tanımlama** (Cloud Function / scheduled trigger)
- [ ] **Görev sistemi (Tasks)**: dinamik yapılandırılabilir görev modeli (reklam izleme, sosyal paylaşım, arkadaş daveti vb.)
- [ ] **Reklam entegrasyonu** ile hak kazanma (`AppAds.dart` mevcut, görev sistemi ile bağlanmalı)
- [ ] **Davet / referans sistemi** (referral code)
- [ ] **Kazanan seçim algoritması** (rastgele, adil)
- [ ] **Kargo / teslimat takibi**
- [ ] **Push bildirimleri** (çekiliş başlangıcı, kazanan duyurusu, günlük hak hatırlatması)

---

## 6. Geliştirme İpuçları

- Renk ve stil sabitlerini **`lib/constants/`** içinden referans ver; widget içinde sabit renk değeri yazma.
- Hata loglamak için `debugPrint()` kullan (`package:flutter/foundation.dart`).
- Cross-platform (Android, iOS, Web) uyumluluğu koru — `dart:io` yerine `file_picker` gibi paketleri tercih et.
- UI metinleri Türkçe olmalıdır (uygulama Türk kullanıcılara yönelik).

---

## 7. Hatırlatma

> 🇹🇷 **Kullanıcıya verilen TÜM cevaplar Türkçe olacaktır. Bu kural istisnasızdır.**

> kontrol ederken bulduğumuz her notu lütfen todo liste eklemeyi ve issuesda açıklama yazmayı unutma

---

## Ek Notlar (Bu sürüm için uyarlamalar)

- Dizin yolu düzeltmesi: Projede renk ve stil sabitleri `lib/Presentation/constants/` altındadır. Yukarıdaki "Geliştirme İpuçları" bölümündeki `lib/constants/` ifadesi proje yapısına uyarlanarak anlaşılmalıdır.
- Dosya adı tutarlılığı notu: `lib/Presentation/providers/ad_reward_profile screen.dart` dosya adında boşluk bulunmaktadır; bu, importlarda sorun çıkarabilir. Ayrıca `buttonEndDate.dart`, `reward_Ad.dart` ve `tagsProvder.dart` isimleri proje geneliyle tutarlı değildir (snake_case önerilir). Bu gözlemler todo ve Issues kaydı olarak açılmıştır.
- Dreamflow/Firebase hatırlatması: Bu projede Firebase entegrasyonu Dreamflow sol kenar çubuğundaki Firebase paneli üzerinden yönetilir. CLI ile kurulum yapmayın; sağlayıcıları ve platformları panelden etkinleştirin.
- Numara sıralaması: Bu dokümanda 3 ve 4 numaralı ana başlıklar kullanıcı tarafından tanımlanmamıştır; mevcut numaralandırma orijinal metne sadık kalınarak korunmuştur.

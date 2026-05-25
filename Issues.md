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

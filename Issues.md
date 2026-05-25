# Issues

## [Gradle] afterEvaluate hatası (root android/build.gradle)
- Hata Mesajı: `Cannot run Project.afterEvaluate(Closure) when the project is already evaluated.`
- Kök Neden: `android/build.gradle` içinde `subprojects { afterEvaluate { ... } }` kullanımı; aynı dosyada `evaluationDependsOn(':app')` bulunduğu için bazı alt projeler çoktan evaluate edilmiş durumdayken yeni `afterEvaluate` kaydı yapılmaya çalışılıyor. Gradle 8/AGP 8 altında bu durum hataya düşüyor.
- Çözüm: `afterEvaluate` bloğu kaldırıldı. Yerine, plugin yükleme anında çalışan güvenli yaklaşım eklendi:
  - `subproject.plugins.withId('com.android.application' | 'com.android.library') { ... }` ile `android` uzantısı üzerinden `namespace` boşsa güvenli varsayılan ataması yapılıyor.
- Etki: Derleme konfigürasyonu sırasında çalıştığı için evaluation sırası ile çakışma yapmıyor; Configuration Cache uyumlu.
- Takip: Uzun vadede üçüncü parti eklentilerin güncel sürümlerine geçildiğinde bu koruyucu blok kaldırılabilir. (bkz. TODO: `todo-plugins-namespace-audit`)

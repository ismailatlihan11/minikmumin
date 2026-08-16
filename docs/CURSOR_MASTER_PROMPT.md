# ÇOCUKLAR İÇİN DİNİ EĞİTİM UYGULAMASI — CURSOR ANA PROJE TALİMATI

## 0. SENİN GÖREVİN

Sen bu projede kıdemli bir Flutter geliştiricisi, mobil UI/UX tasarımcısı, çocuklara yönelik eğitim uygulaması geliştiricisi ve içerik mimarısın.

Bu dokümandaki gereksinimleri doğrudan uygula.

ÖNEMLİ:
- Uygulamayı sadece demo/mockup olarak bırakma.
- Çalışan Flutter uygulaması oluştur.
- Mevcut projede kod varsa önce analiz et, sonra mevcut yapıyı bozmadan geliştir.
- Bir özelliği tamamlamadan başka özelliğe geçme.
- Placeholder metinleri, sahte butonları ve çalışmayan navigation'ları mümkün olduğunca bırakma.
- JSON tabanlı içerik mimarisi kullan.
- İçerikleri UI koduna gömme.
- Uygulama internet olmadan temel içeriklerle çalışabilsin.
- İleride Android ve iOS için build alınabilecek temiz bir mimari kur.
- Çocuklara uygun, sakin, güvenli, İslami hassasiyetlere uygun ve modern bir tasarım kullan.
- Uygulamada kumar, reklam baskısı, uygunsuz içerik, agresif satın alma yönlendirmesi veya çocukları manipüle eden tasarım bulunmasın.
- Gamification kullanılacak ancak dini ibadetleri bir "oyun" gibi küçümseyen bir dil kullanılmayacak.

---

# 1. UYGULAMANIN AMACI

Uygulama çocuklara temel dini bilgileri sevdirerek öğretmek için hazırlanacak.

Ana hedef:

1. Kur'an sevgisi kazandırmak
2. Peygamber Efendimizin hayatını ve güzel ahlakını öğretmek
3. Dua ve zikirleri öğretmek
4. Abdestin nasıl alındığını öğretmek
5. Namazın temel hareketlerini öğretmek
6. Esmaül Hüsna'yı yaşa uygun şekilde tanıtmak
7. İlmihal bilgilerini çocukların anlayabileceği şekilde sunmak
8. Peygamberleri tanıtmak
9. Öğrenilen bilgileri küçük testlerle pekiştirmek
10. Çocuğun ilerlemesini güvenli ve sade şekilde takip etmek

Uygulamanın ana hissi:
"Çocuğun dini öğrenmekten keyif aldığı, sakin, sıcak, güven veren bir dijital kitap + eğitim alanı."

---

# 2. TEKNİK STACK

Flutter kullan.

Tercih:
- Flutter
- Dart
- Material 3
- Riverpod veya mevcut projede kullanılan stabil state management
- go_router veya mevcut navigation mimarisi
- JSON asset tabanlı içerik
- SharedPreferences / Hive / Isar gibi lokal persistence
- flutter_localizations
- gerektiğinde just_audio veya uygun lokal ses çözümü

Mevcut projede farklı ama çalışan bir state management veya navigation yapısı varsa sırf değiştirmek için değiştirme.

Önce proje yapısını analiz et.

---

# 3. GENEL TASARIM DİLİ

Tasarım çocuk uygulaması olmalı fakat aşırı çizgi film görünümünde olmamalı.

İstenen stil:

- İslami
- sıcak
- sade
- modern
- yumuşak
- güven veren
- kitap hissi
- hafif illüstratif
- fazla renk karmaşası olmayan
- okunabilir
- büyük dokunma alanları
- çocukların kolay anlayacağı ikonlar

Ana görsel yaklaşım:

- krem / kırık beyaz arka planlar
- yumuşak yeşil
- açık bej
- altın tonlarında çok sınırlı vurgu
- koyu yeşil yazılar
- gerektiğinde pastel mavi
- kartlarda hafif gölge
- yuvarlatılmış köşeler
- fazla gradient kullanma

AŞIRI NEON RENKLER KULLANMA.

AŞIRI OYUN UYGULAMASI GÖRÜNÜMÜ KULLANMA.

---

# 4. ANA NAVIGATION

Alt navigation 5 ana bölümden oluşsun:

1. Ana Sayfa
2. Öğren
3. Kur'an
4. Dualar
5. Profil

İkonlar:
- Ana Sayfa → ev
- Öğren → kitap / graduation-cap benzeri eğitim ikonu
- Kur'an → açık kitap
- Dualar → dua eden eller / tesbih
- Profil → çocuk dostu profil ikonu

Navigation sade olmalı.

---

# 5. SPLASH SCREEN

Splash ekranı:

- Uygulama logosu
- Uygulama adı
- Çok sade İslami motif
- Hafif animasyon
- Arapça yazı zorunlu değil
- 1-2 saniyeden uzun gereksiz bekleme yapma

Örnek isim:

"Minik Kalpler"

Ancak uygulama adı kodda tek bir constant/config üzerinden değiştirilebilir olsun.

---

# 6. ONBOARDING

İlk açılışta 3-4 ekranlık onboarding.

Sayfalar:

## Sayfa 1
Başlık:
"Dini Bilgileri Sevgiyle Öğren"

Alt metin:
"Kur'an, dua, güzel ahlak ve ibadetleri keşfet."

## Sayfa 2
Başlık:
"Öğren, Uygula, Pekiştir"

Alt metin:
"Abdest, namaz ve duaları adım adım öğren."

## Sayfa 3
Başlık:
"Peygamberleri ve Güzel Ahlakı Tanı"

Alt metin:
"İslam'ın güzel değerlerini hikâyelerle keşfet."

## Sayfa 4
Başlık:
"Haydi Başlayalım"

CTA:
"Başla"

Yaş seçimi gerekiyorsa:
- 4-6
- 7-9
- 10-12

Yaş bilgisi zorunlu değil.
Yaş seçilirse içerik zorluk seviyesini ayarlamak için kullanılabilir.

---

# 7. ANA SAYFA

Ana sayfa çocuğun uygulamaya girdiğinde ne yapacağını hemen anlayacağı şekilde olmalı.

Üst bölüm:

"Selam! 👋"

Altında:
"Bugün birlikte güzel bir şey öğrenelim."

Sonra "Bugünün Öğrenmesi" kartı.

Örnek:
"Abdestte yüzümüzü nasıl yıkarız?"

CTA:
"Öğren"

---

## Ana sayfa kartları

### 1. Bugünün Ayeti
- kısa ayet
- Arapça
- Türkçe anlam
- "Oku"
- favori

### 2. Bugünün Hadisi
- kısa hadis
- kaynak bilgisi
- "Oku"

### 3. Bugünün Duası
- Arapça
- Türkçe
- ses oynatma
- "Tekrar Et"

### 4. Bugünün Esması
- Allah'ın bir ismi
- Arapça
- anlamı
- çocukların anlayacağı kısa açıklama

### 5. Günün Görevi
Örneğin:
"Bugün 1 dua öğren."

Tamamlanınca:
"Tamamlandı"

---

# 8. ÖĞREN BÖLÜMÜ

Öğren ekranında büyük kategori kartları.

Kategoriler:

1. Abdest
2. Namaz
3. Dualar
4. Esmaül Hüsna
5. Peygamberler
6. Güzel Ahlak
7. İlmihal
8. İslami Bilgiler
9. Mini Testler

Her kartın kendine özgü ama aynı tasarım diline sahip illüstrasyonu olsun.

---

# 9. ABDEST MODÜLÜ

Abdest kesinlikle sadece metin olarak verilmemeli.

İnteraktif eğitim şeklinde tasarla.

Akış:

ÖĞREN → ANİMASYON → UYGULA/TIKLA → DOĞRU/YANLIŞ → SES → XP → SONRAKİ ADIM

Adımlar:

1. Niyet / hazırlık
2. Eller
3. Ağız
4. Burun
5. Yüz
6. Kollar
7. Baş
8. Kulaklar
9. Ayaklar
10. Tamamlama

Her adımda:

- kısa açıklama
- görsel/animasyon
- sesli anlatım
- etkileşim
- doğru cevap
- yanlış cevap
- tekrar deneme
- ilerleme göstergesi

Örnek:

"Şimdi ellerimizi yıkamayı öğrenelim."

Çocuk doğru bölgeye dokunur.

Doğru:
"Harika! Ellerimizi güzelce yıkadık."

Yanlış:
"Tekrar deneyelim."

Yanlış cevapta çocuğu utandıran dil kullanma.

---

# 10. ABDEST JSON MİMARİSİ

assets/data/wudu.json

Örnek yapı:

{
  "id": "wudu",
  "title": "Abdest",
  "description": "Abdest almayı adım adım öğren.",
  "steps": [
    {
      "id": "hands",
      "order": 1,
      "title": "Eller",
      "description": "Ellerimizi yıkarız.",
      "image": "assets/images/wudu/hands.png",
      "animation": "assets/animations/wudu/hands.json",
      "audio": "assets/audio/wudu/hands.mp3",
      "interactionType": "tap_area",
      "correctArea": "hands",
      "successMessage": "Aferin! Ellerimizi yıkadık.",
      "retryMessage": "Bir daha deneyelim.",
      "xp": 10
    }
  ]
}

Mimarinin geri kalan adımları aynı yapıyı takip etmeli.

---

# 11. NAMAZ MODÜLÜ

Namaz da aynı interaktif mimariye sahip olmalı.

Ana adımlar:

1. Niyet
2. Tekbir
3. Kıyam
4. Rükû
5. Rükûdan kalkış
6. Secde
7. İki secde arası oturuş
8. Selam

Çocuk:

- hareketi öğrenir
- animasyonu izler
- hareket sırasını öğrenir
- doğru hareketi seçer
- mini test çözer
- dua/tesbihatı öğrenir

Namaz modülünde dini hassasiyet yüksek olmalı.

Fıkhi farklılıklar varsa tek bir görüşü tartışmalı şekilde "tek doğru" diye sunma.
İçerik kaynakları güvenilir şekilde belirtilsin.

---

# 12. NAMAZ JSON

assets/data/prayer.json

Her adım:

- id
- sıra
- başlık
- açıklama
- görsel
- animasyon
- ses
- yapılacak hareket
- okunacak ifade
- doğru cevap
- yanlış cevap
- XP
- tamamlanma

---

# 13. DUALAR

Dualar bölümü kategorilere ayrılabilir.

Örnekler:

- Yemek duası
- Yemekten sonra
- Uyku duası
- Uyanma duası
- Evden çıkarken
- Eve girerken
- Tuvalete girerken
- Tuvaletten çıkarken
- Yolculuk duası
- Anne-baba için dua
- Şükür duası
- Sıkıntı anında dua
- Korku anında okunabilecek dualar

Her dua:

- başlık
- Arapça
- Türkçe okunuş
- Türkçe anlam
- kaynak
- ses
- favori
- tekrar dinle

Dini metinleri uydurma.

---

# 14. ESMAÜL HÜSNA

99 isim.

Her isim:

- sıra
- Arapça
- okunuş
- anlam
- çocukların anlayacağı açıklama
- kısa örnek
- ses
- favori

Örnek:

{
  "id": 1,
  "arabic": "الرَّحْمَنُ",
  "name": "Er-Rahmân",
  "meaning": "Çok merhamet eden",
  "childExplanation": "Allah'ın merhameti bütün kullarını kuşatır.",
  "audio": "assets/audio/asma/1.mp3"
}

---

# 15. PEYGAMBERLER

Peygamberler bölümü.

Her peygamber:

- isim
- Arapça isim
- kısa biyografi
- çocuklara uygun anlatım
- önemli olaylar
- güzel ahlak dersi
- Kur'an'da geçtiği yerler
- ilgili ayetler
- mini test

Peygamberlerin yüzlerini insan figürü olarak çizme.

İllüstrasyon gerekiyorsa:
- sembolik
- manzara
- eşya
- mekân
- ışık
- yol
- kitap
- çöl
gibi temsili görseller kullan.

---

# 16. GÜZEL AHLAK

Çocukların günlük hayatıyla bağlantılı içerikler.

Konular:

- Doğruluk
- Emanet
- Sabır
- Şükür
- Yardımlaşma
- Anne-babaya saygı
- Arkadaşlık
- Affetmek
- Merhamet
- Temizlik
- Adalet
- Sözünde durmak
- Hayvanlara merhamet
- İsraf etmemek

Her konu:

1. Kısa hikâye
2. Ana mesaj
3. Günlük hayattan örnek
4. Mini soru
5. "Bugün bunu deneyelim" görevi

---

# 17. İLMİHAL

Çocuklara uygun sade ilmihal.

Konular:

- Temizlik
- Abdest
- Gusül hakkında yaşa uygun temel bilgi
- Namaz
- Oruç
- Helal / haram kavramları
- Güzel davranışlar
- Cami adabı
- Kur'an adabı

Korkutucu veya aşırı cezalandırıcı dil kullanma.

"Allah seni cezalandırır" merkezli çocuk dili kullanma.

Öncelik:
- sevgi
- merhamet
- güzel davranış
- sorumluluk
- ibadet bilinci

---

# 18. MİNİ TESTLER

Her konu sonunda mini test.

Soru tipleri:

- Çoktan seçmeli
- Doğru / yanlış
- Görsel seçme
- Sıralama
- Eşleştirme

Örnek:

"Abdestte önce hangisini yıkarız?"

A:
"Eller"

B:
"Ayaklar"

C:
"Baş"

Doğru cevap:
"Eller"

Doğru:
"Harika! 🌿"

Yanlış:
"Tekrar düşünelim."

---

# 19. XP / İLERLEME SİSTEMİ

XP kullanılabilir fakat dini ibadetlerin kendisini "puan kazanma yarışı" haline getirme.

XP şu eylemlerden kazanılabilir:

- eğitim tamamlamak
- mini test çözmek
- dua öğrenmek
- peygamber hikâyesi okumak
- güzel ahlak görevi tamamlamak

Örnek:

Abdest dersi:
+10 XP

Mini test:
+5 XP

Dua öğrenme:
+5 XP

Rozetler:

- İlk Ders
- İlk Dua
- Abdest Öğrencisi
- Namazı Keşfediyorum
- Güzel Ahlak
- Peygamberleri Tanıyorum
- 10 Ders
- 25 Ders
- 50 Ders

Rekabetçi leaderboard kullanma.

---

# 20. PROFİL

Profil ekranı sade.

Göster:

- isim / takma ad
- öğrenme seviyesi
- tamamlanan dersler
- öğrenilen dualar
- kazanılan rozetler
- favoriler
- okuma geçmişi

Çocukların kişisel bilgilerini gereksiz şekilde toplama.

Gerçek ad zorunlu olmasın.

---

# 21. EBEVEYN ALANI

Çocuk uygulaması olduğu için ebeveyn alanı ayrı tasarlanmalı.

Ebeveyn alanına girişte basit çocuk kilidi kullanılabilir.

Örneğin:
- basit matematik doğrulaması
- cihazın biyometrik doğrulaması varsa kullanılabilir

Ebeveyn alanında:

- öğrenme ilerlemesi
- tamamlanan konular
- uygulama ayarları
- ses ayarı
- bildirim ayarı
- yaş grubu
- içerik ayarları

Çocuğun kişisel verilerini gereksiz toplama.

---

# 22. FAVORİLER

Favoriler:

- Ayetler
- Hadisler
- Dualar
- Esmalar
- Peygamber hikâyeleri

tek bir favoriler ekranında filtrelenebilir.

Favorilerde gereksiz "yıldız" kullanma.

Kalp/bookmark benzeri sade ikon kullan.

---

# 23. KUR'AN BÖLÜMÜ

Kur'an ekranı kitap hissi vermeli.

Ana ekran:

- Besmele
- Sure listesi
- Arapça sure adı
- sure numarası
- ayet sayısı
- son okunan
- okumaya devam et

Okuma ekranı:

- Arapça metin
- Türkçe meal
- ayet numarası
- yazı boyutu ayarı
- favori
- paylaş
- ses

Arapça metin görsel olarak güçlü olmalı.

Kitap sayfası hissi oluştur.

Kur'an metnini yanlışlıkla değiştirme.

Veri kaynağı güvenilir ve doğrulanabilir olmalı.

Meal için kaynak bilgisi göster.

---

# 24. HADİSLER

Hadis ekranında:

- Arapça varsa Arapça
- Türkçe
- kaynak
- hadis numarası
- konu
- favori

Hadisleri sahihlik durumu belli olmayan kaynaklardan rastgele toplama.

Kaynak bilgisi JSON'da ayrı alan olarak tutulmalı.

---

# 25. GÜNÜN İÇERİĞİ

Ana sayfada her gün:

- Günün Ayeti
- Günün Hadisi
- Günün Duası
- Günün Esması
- Günün güzel davranışı

göster.

random içerik kullanılabilir ancak aynı gün içinde değişmemeli.

Local date üzerinden günlük seed kullan.

---

# 26. OKUMAYA DEVAM ET

Her eğitim / kitap / Kur'an ekranında ilerleme kaydedilmeli.

Örnek:

Kur'an:
sure + ayet

Riyazus-Salihin veya başka kitap:
kitap + bölüm + hadis

Eğitim:
modül + adım

Uygulama kapatılıp açıldığında:
"Okumaya Devam Et"

kartı göster.

---

# 27. SES SİSTEMİ

Sesler lokal asset olarak desteklenmeli.

Her içerik:

audio alanı taşıyabilir.

AudioPlayerService oluştur.

Özellikler:

- play
- pause
- resume
- replay
- volume
- stop

Ses bulunamazsa uygulama çökmemeli.

---

# 28. ANİMASYON SİSTEMİ

Animasyonlar için:

- Lottie
- Rive
- Flutter animation
- gerektiğinde GIF/video

kullanılabilir.

Ancak içerik verisi animasyon dosyasını sadece referans olarak göstermeli.

Örneğin:

"animation": "assets/animations/wudu/hands.json"

Animasyon bulunamazsa statik görsel fallback göster.

---

# 29. JSON DOSYA YAPISI

Şu yapıyı oluştur:

assets/
  data/
    app_config.json
    daily_content.json
    duas.json
    asmaul_husna.json
    prophets.json
    morality.json
    ilmihal.json
    islamic_quiz.json
    wudu.json
    prayer.json
    quran.json
    hadith.json
    achievements.json

  images/
    logo/
    home/
    wudu/
    prayer/
    duas/
    prophets/
    morality/
    islamic/
    quran/

  animations/
    wudu/
    prayer/
    common/

  audio/
    duas/
    asma/
    wudu/
    prayer/
    prophets/

---

# 30. JSON VERİ KURALLARI

Her JSON:

- UTF-8
- geçerli JSON
- trailing comma yok
- ID benzersiz
- içerik UI'a gömülmeyecek
- dosya yolları merkezi asset config ile yönetilebilecek
- kaynak bilgileri ayrı alanlarda tutulacak

Dini metinlerde:
- içerik uydurma
- eksik metni tamamlamaya çalışma
- otomatik anlam üretme
- doğrulanmamış hadisleri sahihmiş gibi gösterme

---

# 31. MODEL SINIFLARI

Flutter tarafında JSON modelleri oluştur.

Örnek:

DailyContent
Dua
AsmaulHusna
Prophet
MoralityLesson
IlmihalLesson
Quiz
QuizQuestion
WuduLesson
WuduStep
PrayerLesson
PrayerStep
QuranSurah
QuranVerse
Hadith
Achievement
UserProgress

Her model:

- fromJson
- toJson

desteklesin.

---

# 32. REPOSITORY MİMARİSİ

UI doğrudan JSON okumamalı.

Örnek:

DataSource
↓
Repository
↓
Provider
↓
UI

Örnek:

QuranRepository
DuaRepository
WuduRepository
PrayerRepository
ProphetRepository
QuizRepository

---

# 33. LOCAL STORAGE

Aşağıdaki bilgiler lokal saklanmalı:

- onboarding tamamlandı mı
- kullanıcı takma adı
- yaş grubu
- favoriler
- son okunan ayet
- son okunan kitap bölümü
- ders ilerlemesi
- XP
- rozetler
- günlük görev durumu
- uygulama ayarları

Kullanıcı verisini gereksiz yere dış sunucuya gönderme.

---

# 34. TEMA

ThemeData merkezi olsun.

Örneğin:

AppColors
AppTextStyles
AppSpacing
AppRadius
AppShadows

oluştur.

Tek tek widgetlarda rastgele renk kullanma.

---

# 35. YAZI BOYUTU

Ayarlar:

- Küçük
- Normal
- Büyük

Arapça yazı için ayrıca:

- Arapça küçük
- Arapça normal
- Arapça büyük

desteklenebilir.

Kur'an okuma ekranında özellikle okunabilirlik öncelikli.

---

# 36. DARK MODE

Dark mode desteklenebilir.

Ancak Kur'an okuma ekranında okunabilirlik bozulmamalı.

Kullanıcı:
- Sistem
- Açık
- Koyu

seçebilsin.

---

# 37. ERİŞİLEBİLİRLİK

Çocuk uygulaması olduğu için:

- büyük butonlar
- yeterli kontrast
- semantic label
- screen reader desteği
- sesli içerik
- minimum 44x44 dokunma alanı
- metin taşmalarına karşı responsive yapı

kullan.

---

# 38. RESPONSIVE

Telefon öncelikli.

Destek:

- küçük Android
- büyük Android
- iPhone
- tablet

Landscape zorunlu değil.

Chrome/Web çalıştırıldığında layout bozulmamalı.

Web'de de responsive davranmalı.

---

# 39. ERROR HANDLING

JSON yüklenemezse:

"İçerik yüklenirken bir sorun oluştu."

Retry butonu.

Ses bulunamazsa:
UI çalışmaya devam etsin.

Görsel bulunamazsa:
placeholder göster.

Crash oluşturacak null değerler bırakma.

---

# 40. LOADING

Her ekran için uygun loading.

Skeleton kullanılabilir.

Boş ekran bırakma.

---

# 41. EMPTY STATE

Örnek:

Favoriler boşsa:

"Henüz favorin yok."

Altında:

"Beğendiğin ayet, dua veya hadisleri buraya ekleyebilirsin."

---

# 42. ARAMA

Global arama ekle.

Arama:

- ayet
- dua
- hadis
- esma
- peygamber
- ilmihal
- güzel ahlak

içinde çalışabilsin.

Sonuçlar kategorili gösterilsin.

---

# 43. PAYLAŞIM

Paylaş butonu:

- ayet
- dua
- hadis
- esma

için kullanılabilir.

Paylaşım metni sade olsun.

Kişisel veri paylaşma.

---

# 44. BİLDİRİMLER

Bildirim sistemi isteğe bağlı.

Örnek:

"Bugünün duasını öğrenmeye ne dersin?"

Ancak çocukları sürekli bildirimle rahatsız etme.

Bildirimler varsayılan olarak agresif olmayacak.

---

# 45. GÜNLÜK GÖREV

Günde maksimum birkaç küçük görev.

Örnek:

- Bir dua öğren
- Bir güzel ahlak konusu oku
- Bir mini test çöz

Tamamlanınca:
"Bugünkü öğrenmeni tamamladın."

---

# 46. ÇOCUK DİLİ

Metinlerde:

KULLAN:
- "Haydi birlikte öğrenelim."
- "Harika!"
- "Tekrar deneyelim."
- "Çok güzel!"
- "Birlikte tekrar bakalım."

KULLANMA:
- "Başarısız oldun."
- "Yanlış yaptın!"
- "Ceza"
- "Kaybettin."
- "Yeterince iyi değilsin."

Dini içerikte korku merkezli gamification yapma.

---

# 47. GÖRSEL KURALLAR

Peygamberlerin yüzlerini göstermeme.

Allah'ı herhangi bir insan, ışık figürü, karakter veya fiziksel varlık şeklinde görselleştirmeme.

Kutsal metinleri dekoratif şekilde bozma.

Arapça metinlerde okunabilirliği önceliklendir.

İslami motifler:
- geometrik desen
- yıldız
- hilal
- kitap
- cami silueti
- bitki
- lale
- kandil
gibi sembolik öğeler olabilir.

---

# 48. ANA SAYFA UI HİYERARŞİSİ

Ana sayfa:

[Selam + Profil]

[Bugünün Öğrenmesi]

[Devam Et]

[Günün Ayeti]

[Günün Hadisi]

[Günün Duası]

[Günün Esması]

[Günün Güzel Davranışı]

[Öğrenme Kategorileri]

---

# 49. ÖĞRENME EKRANI UI

Başlık:
"Haydi Öğrenelim"

Kartlar:

Abdest
Namaz
Dualar
Esmaül Hüsna
Peygamberler
Güzel Ahlak
İlmihal
İslami Bilgiler
Mini Testler

Kartlar çocukların rahatça dokunabileceği büyüklükte olsun.

---

# 50. DERS EKRANI UI

Üst:

< Geri

"Abdest"

[1 / 10]

progress bar

Orta:
Illustration / animation

Alt:
Başlık

Açıklama

[Dinle]

[Bunu Öğrendim]

---

# 51. DOĞRU/YANLIŞ EKRANI

Doğru:
hafif olumlu animasyon
"Harika!"

Yanlış:
sakin animasyon
"Tekrar deneyelim."

Çocuk hatasında ilerleme kaybolmasın.

---

# 52. DERS TAMAMLAMA

Ders sonunda:

"Maşallah! Dersi tamamladın."

Göster:

- öğrenilen konu
- XP
- kazanılan rozet varsa rozet
- sonraki önerilen ders

Butonlar:

"Tekrar Et"
"Sonraki Ders"

---

# 53. KOD KLASÖR YAPISI

lib/
  app/
    app.dart
    routes.dart
    theme/
    constants/

  core/
    services/
    storage/
    audio/
    utils/
    widgets/

  data/
    models/
    datasources/
    repositories/

  features/
    home/
    learn/
    quran/
    duas/
    profile/
    wudu/
    prayer/
    prophets/
    morality/
    ilmihal/
    quiz/
    favorites/
    settings/

  shared/
    widgets/

Bu yapı mevcut projeye uygun şekilde adapte edilebilir.

---

# 54. ÖNEMLİ WIDGETLAR

Tekrar kullanılabilir widgetlar oluştur:

AppCard
SectionHeader
PrimaryButton
SecondaryButton
ArabicText
ContentCard
DailyContentCard
ProgressBar
AudioButton
FavoriteButton
LessonStepCard
QuizOption
AchievementBadge
EmptyState
LoadingView
ErrorView
IllustrationCard

---

# 55. ARAPÇA FONT

Arapça için uygun bir font kullan.

Kur'an metni için font seçimi özellikle dikkatli yapılmalı.

Arapça font ile Türkçe fontu gerekirse ayır.

---

# 56. PERFORMANS

JSON dosyalarını her rebuild'de tekrar parse etme.

Cache kullan.

Liste ekranlarında:

- ListView.builder
- GridView.builder

kullan.

Gereksiz rebuildleri azalt.

Büyük görselleri optimize et.

---

# 57. TEST

En azından:

- JSON parsing testleri
- Repository testleri
- progress storage testleri
- quiz validation testleri
- widget testleri
- navigation testleri

yaz.

Özellikle dini içerik JSON'larında:
- duplicate ID
- boş metin
- bozuk asset path
kontrolleri yap.

---

# 58. CONTENT VALIDATOR

Development sırasında bir validator oluştur.

Örneğin:

dart run tool/validate_content.dart

Çalıştırıldığında:

- JSON geçerli mi?
- duplicate ID var mı?
- zorunlu alan eksik mi?
- asset bulunuyor mu?
- audio path var mı?
- animation path var mı?

kontrol etsin.

---

# 59. APP CONFIG

assets/data/app_config.json

İçinde:

- appName
- version
- minimumAge
- theme
- featureFlags

bulunsun.

Feature flags:

wudu
prayer
quran
hadith
duas
asma
prophets
morality
ilmihal
quiz

---

# 60. İÇERİK KAYNAĞI

Dini içerikler için güvenilir kaynak yaklaşımı kullan.

Her içerikte mümkün olduğunda:

source
sourceName
reference

alanları bulunsun.

Örnek:

"sourceName": "Kur'an-ı Kerim",
"reference": "Bakara 255"

Hadislerde:

"sourceName": "Riyâzü's-Sâlihîn",
"reference": "..."

gibi.

Kaynak kesin değilse kaynak uydurma.

---

# 61. RİYÂZÜ'S-SÂLİHÎN

İleride Riyâzü's-Sâlihîn modülü eklenebilecek şekilde mimari hazırla.

Özellikle:

- uzun içerik
- kısa/özet içerik
- kategori
- hadis
- kaynak
- favori
- kaldığın yerden devam

desteklenebilecek model tasarla.

Ancak mevcut aşamada bu modül zorunlu değilse ana ekranı gereksiz kalabalıklaştırma.

---

# 62. VERİ DOĞRULAMA

Uygulamanın dini içeriğinde en önemli kural:

BİLMİYORSAN UYDURMA.

Bir metin doğrulanmamışsa:
- sahih diye gösterme
- kaynak ekleme
- Arapça metni kendin üretme
- meal uydurma

İçerik verisi eksikse TODO olarak işaretle ve uygulama mimarisini bozmadan ilerle.

---

# 63. GÜVENLİK / ÇOCUK MAHREMİYETİ

Gereksiz kişisel veri toplama.

Çocukların:
- gerçek adı
- adresi
- telefon numarası
- e-posta
- konumu

zorunlu tutulmamalı.

Analytics gerekiyorsa anonim ve minimum veri prensibi uygulanmalı.

---

# 64. REKLAM

Çocuk deneyimini bozan reklam sistemi kurma.

Özellikle dini içerik okuma sırasında reklam gösterme.

İçerik ekranına reklam banner'ı yerleştirme.

---

# 65. SATIN ALMA

Uygulama ücretsiz olacaksa temel dini eğitim içeriğini ödeme duvarı arkasına koyma.

Çocuğa doğrudan satın alma baskısı yapma.

---

# 66. UI MICROCOPY

Ana butonlarda:

"Başla"
"Öğren"
"Dinle"
"Devam Et"
"Tekrar Dene"
"Tekrar Dinle"
"Okumaya Devam Et"
"Favorilere Ekle"
"Tamamladım"

kullan.

---

# 67. UYGULAMA İLK AÇILIŞ AKIŞI

Splash
↓
Onboarding
↓
İsim/takma ad opsiyonel
↓
Yaş grubu opsiyonel
↓
Ana Sayfa

Sonraki açılışlarda:
Splash
↓
Ana Sayfa

---

# 68. ANA SAYFA "DEVAM ET"

Eğer çocuk yarım kalan ders bıraktıysa:

"Devam Et"

kartı ana sayfanın en üst bölümlerinden biri olsun.

Örnek:

"Abdest"
"6. adımdasın"

[Devam Et]

---

# 69. FAVORİLERDE YILDIZ KULLANMA

Favoriler için yıldız ikonunu ana sembol olarak kullanma.

Bookmark veya kalp benzeri sade ikon kullan.

Tasarımda "favori" özelliği dini bir sembol gibi algılanmamalı.

---

# 70. İKONLAR

İkonlar tutarlı olmalı.

Öneri:

- Kur'an → açık kitap
- Dualar → dua elleri
- Esma → zarif Arapça Allah lafzı / İslami tipografik sembol
- Abdest → su damlası + el
- Namaz → seccade / sade ibadet sembolü
- Peygamberler → kitap / yol / yıldız gibi temsili sembol
- Güzel ahlak → kalp
- İlmihal → kitap

Allah lafzını dekoratif bir oyun ikonu haline getirme.

---

# 71. EKRANLARIN TAM LİSTESİ

Aşağıdaki route'ları planla:

/
 /onboarding
 /home
 /learn
 /learn/wudu
 /learn/wudu/step
 /learn/wudu/result
 /learn/prayer
 /learn/prayer/step
 /learn/prayer/result
 /learn/duas
 /learn/duas/detail
 /learn/asma
 /learn/asma/detail
 /learn/prophets
 /learn/prophets/detail
 /learn/morality
 /learn/morality/detail
 /learn/ilmihal
 /learn/ilmihal/detail
 /quiz
 /quiz/play
 /quiz/result
 /quran
 /quran/surah
 /quran/reader
 /favorites
 /profile
 /settings

---

# 72. GELİŞTİRME SIRASI

Projeyi şu sırayla geliştir:

FAZ 1:
- proje analizi
- theme
- navigation
- core architecture
- asset structure

FAZ 2:
- onboarding
- home
- profile
- settings

FAZ 3:
- JSON data layer
- models
- repositories
- local storage

FAZ 4:
- Dualar
- Esma
- Peygamberler
- Güzel Ahlak
- İlmihal

FAZ 5:
- Abdest interaktif modülü

FAZ 6:
- Namaz interaktif modülü

FAZ 7:
- Mini testler
- XP
- rozetler

FAZ 8:
- Kur'an
- Hadis
- favoriler
- okumaya devam et

FAZ 9:
- audio
- animations
- accessibility
- responsive

FAZ 10:
- tests
- validator
- performance
- release preparation

---

# 73. CURSOR ÇALIŞMA KURALI

Her fazdan önce:

1. Mevcut dosyaları tara.
2. Mevcut mimariyi analiz et.
3. Gereksiz dosya oluşturma.
4. Mevcut çalışan özellikleri bozma.
5. Değişiklik planını kısa şekilde belirle.
6. Kodla.
7. `flutter analyze` çalıştır.
8. Uygun testleri çalıştır.
9. Hataları düzelt.
10. Sonraki faza geç.

---

# 74. CURSOR'DA KULLANILACAK KALİTE KRİTERLERİ

Bir özellik "tamamlandı" sayılmadan önce:

- UI çalışıyor
- navigation çalışıyor
- JSON yükleniyor
- null/crash problemi yok
- responsive
- loading state var
- empty state var
- error state var
- favori çalışıyor
- progress kaydediliyor
- gerekiyorsa ses çalışıyor
- gerekiyorsa animasyon çalışıyor
- `flutter analyze` temiz
- ilgili testler geçiyor

---

# 75. KESİNLİKLE YAPMA

- Her ekranı tek Dart dosyasına doldurma.
- UI içine JSON metni gömme.
- Sabit sahte veriyle final uygulama oluşturma.
- Placeholder olarak "Lorem ipsum" bırakma.
- Rastgele hadis/ayet uydurma.
- Dini metinleri otomatik değiştirme.
- Peygamberleri insan yüzüyle görselleştirme.
- Allah'ı fiziksel olarak görselleştirme.
- Çocuğu utandıran hata mesajları kullanma.
- Leaderboard oluşturma.
- Agresif bildirim sistemi kurma.
- Çocuk ekranına reklam doldurma.
- Her butona farklı tasarım uygulama.
- Aşırı renk kullanma.
- Gereksiz animasyon kullanma.
- Web görünümünü bozma.
- Android/iOS responsive yapıyı ihmal etme.

---

# 76. SON KONTROL

Projeyi tamamladıktan sonra şu komutları çalıştır:

flutter pub get
flutter analyze
flutter test

Varsa:

dart run tool/validate_content.dart

Sonuçlarda hata varsa düzelt.

---

# 77. CURSOR'A SON TALİMAT

Bu dokümanı proje ana gereksinim dokümanı olarak kabul et.

Önce mevcut Flutter projesini incele.

Ardından:

1. Eksik mimariyi kur.
2. Theme ve design system oluştur.
3. Navigation oluştur.
4. JSON/data mimarisini oluştur.
5. Ana sayfayı oluştur.
6. Öğren bölümünü oluştur.
7. Abdest interaktif modülünü uygula.
8. Namaz interaktif modülünü uygula.
9. Dualar, Esma, Peygamberler, Güzel Ahlak ve İlmihal bölümlerini uygula.
10. Mini test sistemini uygula.
11. XP ve rozet sistemini uygula.
12. Kur'an ve Hadis altyapısını uygula.
13. Favoriler ve kaldığın yerden devam et sistemini uygula.
14. Audio altyapısını uygula.
15. Responsive ve accessibility kontrollerini yap.
16. Testleri ve content validator'ı ekle.
17. `flutter analyze` ve `flutter test` çalıştır.
18. Hataları düzelt.
19. Uygulamayı çalışır halde bırak.

Kod yazarken mevcut dosyaları gereksiz yere silme.

Mevcut bir özellik daha iyi bir mimariye taşınacaksa önce mevcut davranışı koru.

Amaç:
Çocukların dini bilgileri sevgiyle öğrenebileceği, gerçek bir ürün kalitesinde, güvenilir içerik kullanan, modern ve sakin bir Flutter uygulaması oluşturmak.

ÖNEMLİ:
Bu dokümandaki dini içerik örneklerini yalnızca şema/UX örneği olarak değerlendir. Nihai dini metinleri doğrulanmış veri kaynaklarından al. Doğrulanmamış içerik üretme.

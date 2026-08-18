# Audio sources

Generated: 2026-08-18

The Flutter app is **offline**. It never calls Google Cloud, TTS APIs, or recitation APIs at runtime. Audio is only played from bundled `assets/audio/` files. Missing files hide **Dinle** via `AssetCatalog`.

Quran recitation files are downloaded from official APIs at build/prep time.
Prayer / non-Quran phrases are **not** fetched from the internet.

## Missing non-recitation audio (this APK)

These JSON paths stay bound. Files are not generated or downloaded without a verified license or a separate TTS contract (ADC + Google Cloud TTS). Empty/fake MP3s are not added.

- `assets/audio/prayer/iftitah_tekbir.mp3` — İftitah tekbiri. Namaz Tekbir step is wired (`duaId: iftitah_tekbir`). **MANUAL_REQUIRED**.
- `assets/audio/dhikr/*.mp3` — 8 zikir phrases. Dinle is hidden until files exist.
- `assets/audio/qissalar/*.mp3` — kıssa narration. Cover Dinle is hidden until files exist.
- `assets/audio/prophets/*.mp3`, `assets/audio/asma/*.mp3`, `assets/audio/morality/*.mp3` — same policy.

Existing namaz files under `assets/audio/prayer/` (except iftitah) are **pre-existing local assets**. License: **UNVERIFIED**. They were not replaced and are not fetched at runtime.

Kur'an Öğren educational clips (`assets/audio/quran_learn/`) were **not generated** in this build: Google Application Default Credentials are missing (`gcloud auth application-default login` has not been run). JSON audio paths are already bound; Dinle stays hidden until MP3s are generated and bundled.

## Selected reciter

- Name: Mahmoud Khalil Al-Husary (Muallim)
- Source: Quran.com API v4
- API kind: quran_com
- Reciter id (from API result, not hard-coded in advance): `12`

License: public recitation API. A separate commercial license document was not independently verified.

## Files

### `assets/audio/quran/surah_001.mp3`

- Content: Fâtiha
- Surah / ayah: Surah 001
- Reader: Mahmoud Khalil Al-Husary (Muallim)
- Source: Quran.com API v4
- Source URL: https://download.quranicaudio.com/qdc/khalil_al_husary/muallim/1.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-08-18
- Size: 1012.6 KB
- Status: DOWNLOADED

### `assets/audio/quran/surah_108.mp3`

- Content: Kevser
- Surah / ayah: Surah 108
- Reader: Mahmoud Khalil Al-Husary (Muallim)
- Source: Quran.com API v4
- Source URL: https://download.quranicaudio.com/qdc/khalil_al_husary/muallim/108.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-08-18
- Size: 390.9 KB
- Status: DOWNLOADED

### `assets/audio/quran/surah_112.mp3`

- Content: İhlâs
- Surah / ayah: Surah 112
- Reader: Mahmoud Khalil Al-Husary (Muallim)
- Source: Quran.com API v4
- Source URL: https://download.quranicaudio.com/qdc/khalil_al_husary/muallim/112.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-08-18
- Size: 413.8 KB
- Status: DOWNLOADED

### `assets/audio/quran/surah_103.mp3`

- Content: Asr
- Surah / ayah: Surah 103
- Reader: Mahmoud Khalil Al-Husary (Muallim)
- Source: Quran.com API v4
- Source URL: https://download.quranicaudio.com/qdc/khalil_al_husary/muallim/103.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-08-18
- Size: 576.2 KB
- Status: DOWNLOADED

### `assets/audio/quran/surah_114.mp3`

- Content: Nâs
- Surah / ayah: Surah 114
- Reader: Mahmoud Khalil Al-Husary (Muallim)
- Source: Quran.com API v4
- Source URL: https://download.quranicaudio.com/qdc/khalil_al_husary/muallim/114.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-08-18
- Size: 731.1 KB
- Status: DOWNLOADED

### `assets/audio/quran/surah_113.mp3`

- Content: Felak
- Surah / ayah: Surah 113
- Reader: Mahmoud Khalil Al-Husary (Muallim)
- Source: Quran.com API v4
- Source URL: https://download.quranicaudio.com/qdc/khalil_al_husary/muallim/113.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-08-18
- Size: 589.0 KB
- Status: DOWNLOADED

### `assets/audio/quran/surah_109.mp3`

- Content: Kâfirûn
- Surah / ayah: Surah 109
- Reader: Mahmoud Khalil Al-Husary (Muallim)
- Source: Quran.com API v4
- Source URL: https://download.quranicaudio.com/qdc/khalil_al_husary/muallim/109.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-08-18
- Size: 863.2 KB
- Status: DOWNLOADED

### `assets/audio/quran/surah_110.mp3`

- Content: Nasr
- Surah / ayah: Surah 110
- Reader: Mahmoud Khalil Al-Husary (Muallim)
- Source: Quran.com API v4
- Source URL: https://download.quranicaudio.com/qdc/khalil_al_husary/muallim/110.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-08-18
- Size: 644.8 KB
- Status: DOWNLOADED

### `assets/audio/quran/surah_111.mp3`

- Content: Tebbet
- Surah / ayah: Surah 111
- Reader: Mahmoud Khalil Al-Husary (Muallim)
- Source: Quran.com API v4
- Source URL: https://download.quranicaudio.com/qdc/khalil_al_husary/muallim/111.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-08-18
- Size: 673.4 KB
- Status: DOWNLOADED

### `assets/audio/quran/surah_107.mp3`

- Content: Mâûn
- Surah / ayah: Surah 107
- Reader: Mahmoud Khalil Al-Husary (Muallim)
- Source: Quran.com API v4
- Source URL: https://download.quranicaudio.com/qdc/khalil_al_husary/muallim/107.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-08-18
- Size: 968.9 KB
- Status: DOWNLOADED

### `assets/audio/quran/surah_105.mp3`

- Content: Fîl
- Surah / ayah: Surah 105
- Reader: Mahmoud Khalil Al-Husary (Muallim)
- Source: Quran.com API v4
- Source URL: https://download.quranicaudio.com/qdc/khalil_al_husary/muallim/105.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-08-18
- Size: 805.2 KB
- Status: DOWNLOADED

### `assets/audio/quran/surah_106.mp3`

- Content: Kureyş
- Surah / ayah: Surah 106
- Reader: Mahmoud Khalil Al-Husary (Muallim)
- Source: Quran.com API v4
- Source URL: https://download.quranicaudio.com/qdc/khalil_al_husary/muallim/106.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-08-18
- Size: 663.2 KB
- Status: DOWNLOADED

### `assets/audio/duas/rabbena_atina.mp3`

- Content: Rabbenâ Âtinâ (namaz)
- Surah / ayah: 2:201
- Reader: Mahmoud Khalil Al-Husary (Muallim)
- Source: Quran.com API v4
- Source URL: https://mirrors.quranicaudio.com/everyayah/Husary_Muallim_128kbps/002201.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-08-18
- Size: 602.0 KB
- Status: DOWNLOADED

### `assets/audio/duas/quran_002_201.mp3`

- Content: Rabbenâ Âtinâ
- Surah / ayah: 2:201
- Reader: Mahmoud Khalil Al-Husary (Muallim)
- Source: Quran.com API v4
- Source URL: https://mirrors.quranicaudio.com/everyayah/Husary_Muallim_128kbps/002201.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-08-18
- Size: 602.0 KB
- Status: DOWNLOADED

### `assets/audio/duas/quran_002_286.mp3`

- Content: Rabbenâ Lâ Tüâhiznâ
- Surah / ayah: 2:286
- Reader: Mahmoud Khalil Al-Husary (Muallim)
- Source: Quran.com API v4
- Source URL: https://mirrors.quranicaudio.com/everyayah/Husary_Muallim_128kbps/002286.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-08-18
- Size: 1.5 MB
- Status: DOWNLOADED

### `assets/audio/duas/quran_003_008.mp3`

- Content: Rabbenâ Lâ Tüzığ Kulûbenâ
- Surah / ayah: 3:8
- Reader: Mahmoud Khalil Al-Husary (Muallim)
- Source: Quran.com API v4
- Source URL: https://mirrors.quranicaudio.com/everyayah/Husary_Muallim_128kbps/003008.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-08-18
- Size: 340.0 KB
- Status: DOWNLOADED

### `assets/audio/duas/quran_003_016.mp3`

- Content: Rabbenâ İnnenâ Âmennâ
- Surah / ayah: 3:16
- Reader: Mahmoud Khalil Al-Husary (Muallim)
- Source: Quran.com API v4
- Source URL: https://mirrors.quranicaudio.com/everyayah/Husary_Muallim_128kbps/003016.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-08-18
- Size: 464.0 KB
- Status: DOWNLOADED

### `assets/audio/duas/quran_003_053.mp3`

- Content: Rabbenâ Âmennâ
- Surah / ayah: 3:53
- Reader: Mahmoud Khalil Al-Husary (Muallim)
- Source: Quran.com API v4
- Source URL: https://mirrors.quranicaudio.com/everyayah/Husary_Muallim_128kbps/003053.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-08-18
- Size: 368.0 KB
- Status: DOWNLOADED

### `assets/audio/duas/quran_007_023.mp3`

- Content: Rabbenâ Zalemnâ
- Surah / ayah: 7:23
- Reader: Mahmoud Khalil Al-Husary (Muallim)
- Source: Quran.com API v4
- Source URL: https://mirrors.quranicaudio.com/everyayah/Husary_Muallim_128kbps/007023.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-08-18
- Size: 372.0 KB
- Status: DOWNLOADED

### `assets/audio/duas/quran_007_126.mp3`

- Content: Rabbenâ Efrığ Aleynâ
- Surah / ayah: 7:126
- Reader: Mahmoud Khalil Al-Husary (Muallim)
- Source: Quran.com API v4
- Source URL: https://mirrors.quranicaudio.com/everyayah/Husary_Muallim_128kbps/007126.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-08-18
- Size: 590.0 KB
- Status: DOWNLOADED

### `assets/audio/duas/quran_014_040.mp3`

- Content: Rabbi'c'alnî Mukîme's-Salâti
- Surah / ayah: 14:40
- Reader: Mahmoud Khalil Al-Husary (Muallim)
- Source: Quran.com API v4
- Source URL: https://mirrors.quranicaudio.com/everyayah/Husary_Muallim_128kbps/014040.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-08-18
- Size: 376.0 KB
- Status: DOWNLOADED

### `assets/audio/duas/quran_014_041.mp3`

- Content: Rabbenâğfir Lî
- Surah / ayah: 14:41
- Reader: Mahmoud Khalil Al-Husary (Muallim)
- Source: Quran.com API v4
- Source URL: https://mirrors.quranicaudio.com/everyayah/Husary_Muallim_128kbps/014041.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-08-18
- Size: 254.0 KB
- Status: DOWNLOADED

### `assets/audio/duas/quran_018_010.mp3`

- Content: Rabbenâ Âtinâ (Kehf)
- Surah / ayah: 18:10
- Reader: Mahmoud Khalil Al-Husary (Muallim)
- Source: Quran.com API v4
- Source URL: https://mirrors.quranicaudio.com/everyayah/Husary_Muallim_128kbps/018010.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-08-18
- Size: 494.0 KB
- Status: DOWNLOADED

### `assets/audio/duas/quran_020_025.mp3`

- Content: Rabbi'şrah Lî Sadrî
- Surah / ayah: 20:25
- Reader: Mahmoud Khalil Al-Husary (Muallim)
- Source: Quran.com API v4
- Source URL: https://mirrors.quranicaudio.com/everyayah/Husary_Muallim_128kbps/020025.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-08-18
- Size: 110.0 KB
- Status: DOWNLOADED

### `assets/audio/duas/quran_020_114.mp3`

- Content: Rabbi Zıdnî İlmâ
- Surah / ayah: 20:114
- Reader: Mahmoud Khalil Al-Husary (Muallim)
- Source: Quran.com API v4
- Source URL: https://mirrors.quranicaudio.com/everyayah/Husary_Muallim_128kbps/020114.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-08-18
- Size: 484.0 KB
- Status: DOWNLOADED

### `assets/audio/duas/quran_021_083.mp3`

- Content: Rabbi Ennî Messeniye'd-Durru
- Surah / ayah: 21:83
- Reader: Mahmoud Khalil Al-Husary (Muallim)
- Source: Quran.com API v4
- Source URL: https://mirrors.quranicaudio.com/everyayah/Husary_Muallim_128kbps/021083.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-08-18
- Size: 312.0 KB
- Status: DOWNLOADED

### `assets/audio/duas/quran_021_087.mp3`

- Content: Lâ İlâhe İllâ Ente
- Surah / ayah: 21:87
- Reader: Mahmoud Khalil Al-Husary (Muallim)
- Source: Quran.com API v4
- Source URL: https://mirrors.quranicaudio.com/everyayah/Husary_Muallim_128kbps/021087.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-08-18
- Size: 712.0 KB
- Status: DOWNLOADED

### `assets/audio/duas/quran_023_097.mp3`

- Content: Rabbi Eûzü Bike
- Surah / ayah: 23:97
- Reader: Mahmoud Khalil Al-Husary (Muallim)
- Source: Quran.com API v4
- Source URL: https://mirrors.quranicaudio.com/everyayah/Husary_Muallim_128kbps/023097.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-08-18
- Size: 178.0 KB
- Status: DOWNLOADED

### `assets/audio/duas/quran_023_118.mp3`

- Content: Rabbiğfir Verham
- Surah / ayah: 23:118
- Reader: Mahmoud Khalil Al-Husary (Muallim)
- Source: Quran.com API v4
- Source URL: https://mirrors.quranicaudio.com/everyayah/Husary_Muallim_128kbps/023118.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-08-18
- Size: 164.0 KB
- Status: DOWNLOADED

### `assets/audio/duas/quran_025_074.mp3`

- Content: Rabbenâ Hevvinâ
- Surah / ayah: 25:74
- Reader: Mahmoud Khalil Al-Husary (Muallim)
- Source: Quran.com API v4
- Source URL: https://mirrors.quranicaudio.com/everyayah/Husary_Muallim_128kbps/025074.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-08-18
- Size: 474.0 KB
- Status: DOWNLOADED

### `assets/audio/duas/quran_028_024.mp3`

- Content: Rabbi İnnî Limâ Enzelte
- Surah / ayah: 28:24
- Reader: Mahmoud Khalil Al-Husary (Muallim)
- Source: Quran.com API v4
- Source URL: https://mirrors.quranicaudio.com/everyayah/Husary_Muallim_128kbps/028024.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-08-18
- Size: 512.0 KB
- Status: DOWNLOADED

### `assets/audio/duas/quran_059_010.mp3`

- Content: Rabbenâğfir Lenâ
- Surah / ayah: 59:10
- Reader: Mahmoud Khalil Al-Husary (Muallim)
- Source: Quran.com API v4
- Source URL: https://mirrors.quranicaudio.com/everyayah/Husary_Muallim_128kbps/059010.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-08-18
- Size: 784.0 KB
- Status: DOWNLOADED

### `assets/audio/duas/quran_066_008.mp3`

- Content: Rabbenâ Etmim Lenâ Nûrenâ
- Surah / ayah: 66:8
- Reader: Mahmoud Khalil Al-Husary (Muallim)
- Source: Quran.com API v4
- Source URL: https://mirrors.quranicaudio.com/everyayah/Husary_Muallim_128kbps/066008.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-08-18
- Size: 1.5 MB
- Status: DOWNLOADED

### `assets/audio/prayer/besmele.mp3`

- Content: Besmele
- Surah / ayah: —
- Reader: unknown (pre-existing file)
- Source: local asset (license not verified)
- Source URL: —
- License: UNVERIFIED
- Download date: 2026-08-18
- Size: 50.2 KB
- Status: MANUAL_REVIEW_REQUIRED
- Note: Pre-existing local file. License was not verified; file was not replaced.

### `assets/audio/prayer/hamdele.mp3`

- Content: Hamdele
- Surah / ayah: —
- Reader: unknown (pre-existing file)
- Source: local asset (license not verified)
- Source URL: —
- License: UNVERIFIED
- Download date: 2026-08-18
- Size: 39.8 KB
- Status: MANUAL_REVIEW_REQUIRED
- Note: Pre-existing local file. License was not verified; file was not replaced.

### `assets/audio/prayer/kelime_i_tevhid.mp3`

- Content: Kelime-i Tevhid
- Surah / ayah: —
- Reader: unknown (pre-existing file)
- Source: local asset (license not verified)
- Source URL: —
- License: UNVERIFIED
- Download date: 2026-08-18
- Size: 76.5 KB
- Status: MANUAL_REVIEW_REQUIRED
- Note: Pre-existing local file. License was not verified; file was not replaced.

### `assets/audio/prayer/kelime_i_sehadet.mp3`

- Content: Kelime-i Şehadet
- Surah / ayah: —
- Reader: unknown (pre-existing file)
- Source: local asset (license not verified)
- Source URL: —
- License: UNVERIFIED
- Download date: 2026-08-18
- Size: 120.6 KB
- Status: MANUAL_REVIEW_REQUIRED
- Note: Pre-existing local file. License was not verified; file was not replaced.

### `assets/audio/prayer/subhaneke.mp3`

- Content: Sübhaneke
- Surah / ayah: —
- Reader: unknown (pre-existing file)
- Source: local asset (license not verified)
- Source URL: —
- License: UNVERIFIED
- Download date: 2026-08-18
- Size: 146.4 KB
- Status: MANUAL_REVIEW_REQUIRED
- Note: Pre-existing local file. License was not verified; file was not replaced.

### `assets/audio/prayer/tahiyyat.mp3`

- Content: Et-Tahiyyâtü
- Surah / ayah: —
- Reader: unknown (pre-existing file)
- Source: local asset (license not verified)
- Source URL: —
- License: UNVERIFIED
- Download date: 2026-08-18
- Size: 368.4 KB
- Status: MANUAL_REVIEW_REQUIRED
- Note: Pre-existing local file. License was not verified; file was not replaced.

### `assets/audio/prayer/allahumme_salli.mp3`

- Content: Allahümme Salli
- Surah / ayah: —
- Reader: unknown (pre-existing file)
- Source: local asset (license not verified)
- Source URL: —
- License: UNVERIFIED
- Download date: 2026-08-18
- Size: 397.0 KB
- Status: MANUAL_REVIEW_REQUIRED
- Note: Pre-existing local file. License was not verified; file was not replaced.

### `assets/audio/prayer/allahumme_barik.mp3`

- Content: Allahümme Bârik
- Surah / ayah: —
- Reader: unknown (pre-existing file)
- Source: local asset (license not verified)
- Source URL: —
- License: UNVERIFIED
- Download date: 2026-08-18
- Size: 197.3 KB
- Status: MANUAL_REVIEW_REQUIRED
- Note: Pre-existing local file. License was not verified; file was not replaced.

### `assets/audio/prayer/rabbena_gfirli.mp3`

- Content: Rabbenâğfir Lî
- Surah / ayah: —
- Reader: unknown (pre-existing file)
- Source: local asset (license not verified)
- Source URL: —
- License: UNVERIFIED
- Download date: 2026-08-18
- Size: 93.3 KB
- Status: MANUAL_REVIEW_REQUIRED
- Note: Pre-existing local file. License was not verified; file was not replaced.

### `assets/audio/prayer/iftitah_tekbir.mp3`

- Content: İftitah Tekbiri
- Surah / ayah: —
- Reader: —
- Source: not downloaded
- Source URL: —
- License: UNVERIFIED
- Download date: 2026-08-18
- Size: —
- Status: MANUAL_REQUIRED
- Note: No verified license. Do not download from random websites or YouTube.

### `assets/audio/prayer/ruku_tesbihi.mp3`

- Content: Rükû Tesbihi
- Surah / ayah: —
- Reader: unknown (pre-existing file)
- Source: local asset (license not verified)
- Source URL: —
- License: UNVERIFIED
- Download date: 2026-08-18
- Size: 42.7 KB
- Status: MANUAL_REVIEW_REQUIRED
- Note: Pre-existing local file. License was not verified; file was not replaced.

### `assets/audio/prayer/rukudan_dogrulurken.mp3`

- Content: Rükûdan Doğrulma
- Surah / ayah: —
- Reader: unknown (pre-existing file)
- Source: local asset (license not verified)
- Source URL: —
- License: UNVERIFIED
- Download date: 2026-08-18
- Size: 80.8 KB
- Status: MANUAL_REVIEW_REQUIRED
- Note: Pre-existing local file. License was not verified; file was not replaced.

### `assets/audio/prayer/sujud_tesbihi.mp3`

- Content: Secde Tesbihi
- Surah / ayah: —
- Reader: unknown (pre-existing file)
- Source: local asset (license not verified)
- Source URL: —
- License: UNVERIFIED
- Download date: 2026-08-18
- Size: 40.9 KB
- Status: MANUAL_REVIEW_REQUIRED
- Note: Pre-existing local file. License was not verified; file was not replaced.

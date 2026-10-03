# Audio sources

Generated: 2026-08-18

The Flutter app is **offline**. It never calls Google Cloud, TTS APIs, or recitation APIs at runtime. Audio is only played from bundled `assets/audio/` files. Missing files hide **Dinle** via `AssetCatalog`.

Quran recitation files are downloaded from official APIs at build/prep time.
Prayer / non-Quran phrases are **not** fetched from the internet.

## Educational Arabic audio (namaz, dualar, esma, Kur'an Öğren)

Runtime stays offline. Provenance details for free replacements live in
`docs/quran_learn_audio_sources.md` and
`assets/audio/quran_learn/free_audio_manifest.json`.

- **Alphabet letter names:** MIT recordings from [Alfathon](https://github.com/kholmatov/alfathon) (`quran_learn/alphabet/`, see `ATTRIBUTION.md`)
- **Short educational surahs** (`quran_learn/surahs/`): Yasir ed-Devseri copies of `assets/audio/quran/`
- **Kur'an-ı Kerim tilavet:** Yasir ed-Devseri (`assets/audio/quran/` + `ayahs/` + Kur’an dua ayetleri)
- **Esmaül Hüsna (`asma/01–99.mp3`):** human recordings from the MIT-licensed [esmaulhusna_muslimbg](https://pub.dev/packages/esmaulhusna_muslimbg) 1.0.9 package (`lib/assets/audio/`), trimmed and loudness-normalised to −16 LUFS. Reciter/recording origin is not stated upstream; confirm with the author before release. The same files (byte-identical, e.g. `wahid.mp3`) already ship in the MIT-licensed [MohammedAbidNafi/99-Names-of-Allah](https://github.com/MohammedAbidNafi/99-Names-of-Allah) Android app (2021), which also has no El-Ehad clip, so the voice predates both repos. The app no longer shows license notices in-app, so the MIT notice must be included elsewhere (e.g. the store listing or privacy page). `67.mp3` (El-Ehad) stays Fenrir: upstream `67_Ал-Ахад.mp3` is a different 48 kHz recording that is cut off mid-word.
- **Still Fenrir / non-Dosari:** hareke drills (`exercises/`, syllables…), alphabet (Alfathon), asma `67.mp3`, namaz duaları (Sübhaneke, Tahiyyat, tekbir, tesbihler…)
- **Dualar (günlük dualar, `assets/data/duas.json`):** intentionally no audio; text only
- **Kelime-i Şehadet:** Wikimedia Commons real recitation (CC BY-SA 3.0), not TTS
- **Eûzü + Besmele / Besmele:** Yasir ed-Devseri (EveryAyah `001000` + `001001`; same voice as yasseraldosary.com surah stream)
- **Quranic namaz duaları now Dosari:** Rabbenâ Âtinâ (2:201), Rabbenâğfir Lî (14:41), besmele, all bundled surahs/ayahs

Re-import free packs:

```bash
python3 scripts/fetch_free_educational_audio.py --force
```

## Selected reciter

- Name: Yasser Al-Dosari (Yasir ed-Devseri)
- Source: Quranicaudio (`yasser_ad-dussary`) + EveryAyah `Yasser_Ad-Dussary_128kbps`
- API kind: quranicaudio / everyayah
- Reciter slug: `yasser_ad-dussary`

License: public recitation CDN. A separate commercial license document was not independently verified.


## Files

### `assets/audio/quran/surah_001.mp3`

- Content: Fâtiha
- Surah / ayah: Surah 001
- Reader: Yasser Al-Dosari (Yasir ed-Devseri)
- Source: Quranicaudio (`yasser_ad-dussary`)
- Source URL: https://download.quranicaudio.com/quran/yasser_ad-dussary/001.mp3
- License: UNVERIFIED (public recitation CDN; no separate license file found)
- Download date: 2026-09-16
- Size: 758.5 KB
- Status: DOWNLOADED
- Note: Also copied to `assets/audio/quran_learn/surahs/surah_001.mp3`. Per-ayah clips under `assets/audio/quran/ayahs/` from EveryAyah `Yasser_Ad-Dussary_128kbps`.


### `assets/audio/quran/surah_108.mp3`

- Content: Kevser
- Surah / ayah: Surah 108
- Reader: Yasser Al-Dosari (Yasir ed-Devseri)
- Source: Quranicaudio (`yasser_ad-dussary`)
- Source URL: https://download.quranicaudio.com/quran/yasser_ad-dussary/108.mp3
- License: UNVERIFIED (public recitation CDN; no separate license file found)
- Download date: 2026-09-16
- Size: 205.4 KB
- Status: DOWNLOADED
- Note: Also copied to `assets/audio/quran_learn/surahs/surah_108.mp3`. Per-ayah clips under `assets/audio/quran/ayahs/` from EveryAyah `Yasser_Ad-Dussary_128kbps`.


### `assets/audio/quran/surah_112.mp3`

- Content: İhlâs
- Surah / ayah: Surah 112
- Reader: Yasser Al-Dosari (Yasir ed-Devseri)
- Source: Quranicaudio (`yasser_ad-dussary`)
- Source URL: https://download.quranicaudio.com/quran/yasser_ad-dussary/112.mp3
- License: UNVERIFIED (public recitation CDN; no separate license file found)
- Download date: 2026-09-16
- Size: 186.6 KB
- Status: DOWNLOADED
- Note: Also copied to `assets/audio/quran_learn/surahs/surah_112.mp3`. Per-ayah clips under `assets/audio/quran/ayahs/` from EveryAyah `Yasser_Ad-Dussary_128kbps`.


### `assets/audio/quran/surah_103.mp3`

- Content: Asr
- Surah / ayah: Surah 103
- Reader: Yasser Al-Dosari (Yasir ed-Devseri)
- Source: Quranicaudio (`yasser_ad-dussary`)
- Source URL: https://download.quranicaudio.com/quran/yasser_ad-dussary/103.mp3
- License: UNVERIFIED (public recitation CDN; no separate license file found)
- Download date: 2026-09-16
- Size: 275.6 KB
- Status: DOWNLOADED
- Note: Also copied to `assets/audio/quran_learn/surahs/surah_103.mp3`. Per-ayah clips under `assets/audio/quran/ayahs/` from EveryAyah `Yasser_Ad-Dussary_128kbps`.


### `assets/audio/quran/surah_114.mp3`

- Content: Nâs
- Surah / ayah: Surah 114
- Reader: Yasser Al-Dosari (Yasir ed-Devseri)
- Source: Quranicaudio (`yasser_ad-dussary`)
- Source URL: https://download.quranicaudio.com/quran/yasser_ad-dussary/114.mp3
- License: UNVERIFIED (public recitation CDN; no separate license file found)
- Download date: 2026-09-16
- Size: 566.6 KB
- Status: DOWNLOADED
- Note: Also copied to `assets/audio/quran_learn/surahs/surah_114.mp3`. Per-ayah clips under `assets/audio/quran/ayahs/` from EveryAyah `Yasser_Ad-Dussary_128kbps`.


### `assets/audio/quran/surah_113.mp3`

- Content: Felak
- Surah / ayah: Surah 113
- Reader: Yasser Al-Dosari (Yasir ed-Devseri)
- Source: Quranicaudio (`yasser_ad-dussary`)
- Source URL: https://download.quranicaudio.com/quran/yasser_ad-dussary/113.mp3
- License: UNVERIFIED (public recitation CDN; no separate license file found)
- Download date: 2026-09-16
- Size: 332.7 KB
- Status: DOWNLOADED
- Note: Also copied to `assets/audio/quran_learn/surahs/surah_113.mp3`. Per-ayah clips under `assets/audio/quran/ayahs/` from EveryAyah `Yasser_Ad-Dussary_128kbps`.


### `assets/audio/quran/surah_109.mp3`

- Content: Kâfirûn
- Surah / ayah: Surah 109
- Reader: Yasser Al-Dosari (Yasir ed-Devseri)
- Source: Quranicaudio (`yasser_ad-dussary`)
- Source URL: https://download.quranicaudio.com/quran/yasser_ad-dussary/109.mp3
- License: UNVERIFIED (public recitation CDN; no separate license file found)
- Download date: 2026-09-16
- Size: 565.0 KB
- Status: DOWNLOADED
- Note: Also copied to `assets/audio/quran_learn/surahs/surah_109.mp3`. Per-ayah clips under `assets/audio/quran/ayahs/` from EveryAyah `Yasser_Ad-Dussary_128kbps`.


### `assets/audio/quran/surah_110.mp3`

- Content: Nasr
- Surah / ayah: Surah 110
- Reader: Yasser Al-Dosari (Yasir ed-Devseri)
- Source: Quranicaudio (`yasser_ad-dussary`)
- Source URL: https://download.quranicaudio.com/quran/yasser_ad-dussary/110.mp3
- License: UNVERIFIED (public recitation CDN; no separate license file found)
- Download date: 2026-09-16
- Size: 324.2 KB
- Status: DOWNLOADED
- Note: Also copied to `assets/audio/quran_learn/surahs/surah_110.mp3`. Per-ayah clips under `assets/audio/quran/ayahs/` from EveryAyah `Yasser_Ad-Dussary_128kbps`.


### `assets/audio/quran/surah_111.mp3`

- Content: Tebbet
- Surah / ayah: Surah 111
- Reader: Yasser Al-Dosari (Yasir ed-Devseri)
- Source: Quranicaudio (`yasser_ad-dussary`)
- Source URL: https://download.quranicaudio.com/quran/yasser_ad-dussary/111.mp3
- License: UNVERIFIED (public recitation CDN; no separate license file found)
- Download date: 2026-09-16
- Size: 388.3 KB
- Status: DOWNLOADED
- Note: Also copied to `assets/audio/quran_learn/surahs/surah_111.mp3`. Per-ayah clips under `assets/audio/quran/ayahs/` from EveryAyah `Yasser_Ad-Dussary_128kbps`.


### `assets/audio/quran/surah_107.mp3`

- Content: Mâûn
- Surah / ayah: Surah 107
- Reader: Yasser Al-Dosari (Yasir ed-Devseri)
- Source: Quranicaudio (`yasser_ad-dussary`)
- Source URL: https://download.quranicaudio.com/quran/yasser_ad-dussary/107.mp3
- License: UNVERIFIED (public recitation CDN; no separate license file found)
- Download date: 2026-09-16
- Size: 424.6 KB
- Status: DOWNLOADED
- Note: Also copied to `assets/audio/quran_learn/surahs/surah_107.mp3`. Per-ayah clips under `assets/audio/quran/ayahs/` from EveryAyah `Yasser_Ad-Dussary_128kbps`.


### `assets/audio/quran/surah_105.mp3`

- Content: Fîl
- Surah / ayah: Surah 105
- Reader: Yasser Al-Dosari (Yasir ed-Devseri)
- Source: Quranicaudio (`yasser_ad-dussary`)
- Source URL: https://download.quranicaudio.com/quran/yasser_ad-dussary/105.mp3
- License: UNVERIFIED (public recitation CDN; no separate license file found)
- Download date: 2026-09-16
- Size: 389.5 KB
- Status: DOWNLOADED
- Note: Also copied to `assets/audio/quran_learn/surahs/surah_105.mp3`. Per-ayah clips under `assets/audio/quran/ayahs/` from EveryAyah `Yasser_Ad-Dussary_128kbps`.


### `assets/audio/quran/surah_106.mp3`

- Content: Kureyş
- Surah / ayah: Surah 106
- Reader: Yasser Al-Dosari (Yasir ed-Devseri)
- Source: Quranicaudio (`yasser_ad-dussary`)
- Source URL: https://download.quranicaudio.com/quran/yasser_ad-dussary/106.mp3
- License: UNVERIFIED (public recitation CDN; no separate license file found)
- Download date: 2026-09-16
- Size: 323.8 KB
- Status: DOWNLOADED
- Note: Also copied to `assets/audio/quran_learn/surahs/surah_106.mp3`. Per-ayah clips under `assets/audio/quran/ayahs/` from EveryAyah `Yasser_Ad-Dussary_128kbps`.


### `assets/audio/duas/rabbena_atina.mp3`

- Content: Rabbenâ Âtinâ (dua clause only — matches namaz/dualar okunuş)
- Surah / ayah: 2:201
- Reader: Yasser Al-Dosari (Yasir ed-Devseri)
- Source: Cropped from EveryAyah `Yasser_Ad-Dussary_128kbps` `002201.mp3` (full backup: `audio_backups/duas/quran_002_201_full.mp3`)
- Source URL: https://everyayah.com/data/Yasser_Ad-Dussary_128kbps/002201.mp3
- License: UNVERIFIED (public recitation CDN; no separate license file found)
- Download date: 2026-09-16
- Updated: 2026-09-18 — removed ayah opening «وَمِنْهُمْ مَنْ يَقُولُ» so clip starts at «رَبَّنَا آتِنَا…»
- Size: ~310 KB
- Status: DOWNLOADED
- Updated: 2026-10-03 — trimmed a further 2.08s leftover «يَقُولُ» tail at the start (cut at the breath pause before «رَبَّنَا»)
- Note: Duration ~15.8s.

### `assets/audio/duas/quran_014_041.mp3`

- Content: Rabbenâğfir Lî
- Surah / ayah: 14:41
- Reader: Yasser Al-Dosari (Yasir ed-Devseri)
- Source: EveryAyah `Yasser_Ad-Dussary_128kbps`
- Source URL: https://everyayah.com/data/Yasser_Ad-Dussary_128kbps/014041.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-09-16
- Size: 254.0 KB
- Status: DOWNLOADED

### `assets/audio/duas/quran_023_097.mp3`

- Content: Rabbi Eûzü Bike
- Surah / ayah: 23:97
- Reader: Yasser Al-Dosari (Yasir ed-Devseri)
- Source: EveryAyah `Yasser_Ad-Dussary_128kbps`
- Source URL: https://everyayah.com/data/Yasser_Ad-Dussary_128kbps/023097.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-09-16
- Size: 178.0 KB
- Status: DOWNLOADED

### `assets/audio/prayer/besmele.mp3`

- Content: Besmele (`بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيمِ`)
- Surah / ayah: Fâtiha 1:1
- Reader: Yasser Al-Dosari (Yasir ed-Devseri)
- Source: EveryAyah `Yasser_Ad-Dussary_128kbps` `001001.mp3`
- Source URL: https://everyayah.com/data/Yasser_Ad-Dussary_128kbps/001001.mp3
- License: UNVERIFIED (public recitation CDN; no separate license file found)
- Download date: 2026-09-16
- Size: ~54 KB (~3.3 s)
- Status: DOWNLOADED
- Note: Replaced mislabeled `001000.mp3` (user reported it as eûzü). `001001` is Fâtiha 1:1 Bismillah; same bytes as `assets/audio/quran/ayahs/001_001.mp3`.

### `assets/audio/prayer/euzu_besmele.mp3`

- Content: Eûzü + Besmele (`أَعُوذُ بِاللّٰهِ مِنَ الشَّيْطَانِ الرَّجِيمِ` then `بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيمِ`)
- Surah / ayah: —
- Reader: Yasser Al-Dosari (Yasir ed-Devseri)
- Source: EveryAyah `Yasser_Ad-Dussary_128kbps` `001000.mp3` + `001001.mp3` joined with ~350 ms silence
- Source URL: https://everyayah.com/data/Yasser_Ad-Dussary_128kbps/001000.mp3 + `001001.mp3`
- License: UNVERIFIED (public recitation CDN; no separate license file found)
- Download date: 2026-09-16
- Size: ~118 KB (~7.5 s)
- Status: DOWNLOADED
- Note: Official site https://www.yasseraldosary.com/ only hosts full surahs via `server11.mp3quran.net/yasser/` (no separate istiadha/basmala clip). Same reciter: EveryAyah `001000` is the Dosari eûzü clip; `001001` is Fâtiha 1:1 Bismillah.

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

- Content: Kelime-i Tevhid (`لَا إِلٰهَ إِلَّا اللّٰهُ` only; not Kelime-i Şehadet)
- Surah / ayah: —
- Reader: Hisn al-Muslim recitation (hisnmuslim.com collection)
- Source: Hisnul Muslim 153 — `sheikhhanif/Hisnul_Muslim_Database` `audio/153hm.mp3`
- Source URL: https://github.com/sheikhhanif/Hisnul_Muslim_Database
- License: UNVERIFIED (same Hisn al-Muslim dawah collection as other clips)
- Download date: 2026-09-07
- Size: 19.7 KB
- Status: DOWNLOADED
- Note: Real recitation, not TTS. Hisn 153 is the isolated tahlil (`لَا إلَهَ إلَّا اللهُ`), not the adhan and not Kelime-i Şehadet.

### `assets/audio/prayer/rabbena_lekel_hamd.mp3`

- Content: Rabbenâ Lekel-Hamd (`رَبَّنَا وَلَكَ الْحَمْدُ` only)
- Surah / ayah: —
- Reader: Hisn al-Muslim recitation (hisnmuslim.com collection)
- Source: Hisn al-Muslim 39 — first phrase cropped from `hisnmuslim.com/audio/ar/39.mp3`
- Source URL: http://www.hisnmuslim.com/audio/ar/39.mp3
- License: UNVERIFIED (same Hisn al-Muslim dawah collection as other clips)
- Download date: 2026-09-06
- Size: 39.6 KB
- Status: DOWNLOADED
- Note: Real recitation, not TTS. The source file continues with `حَمْدًا كَثِيرًا طَيِّبًا مُبَارَكًا فِيهِ`; that ending was cut after the pause so the clip matches the short namaz phrase.

### `assets/audio/prayer/kelime_i_sehadet.mp3`

- Content: Kelime-i Şehadet (Islamic declaration of faith / Shahada)
- Surah / ayah: —
- Reader: Hisn al-Muslim recitation (same clip family as tahiyyat)
- Source: Cropped from `assets/audio/prayer/tahiyyat.mp3` (Hisnul Muslim 52 / `52hm.mp3`) — final tashahhud phrase only
- Source URL: https://github.com/sheikhhanif/Hisnul_Muslim_Database
- License: UNVERIFIED (same Hisn al-Muslim dawah collection as tahiyyat)
- Download date: 2026-09-18
- Size: ~124 KB (~7.9 s)
- Status: DOWNLOADED
- Note: Matches on-screen Diyanet wording: أَشْهَدُ أَنْ لَا إِلٰهَ إِلَّا اللّٰهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ (“…Muhammeden abdühû ve resûlüh”). Replaces Wikimedia short form that omitted عبدُه.


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

- Content: Et-Tahiyyâtü (tashahhud)
- Surah / ayah: —
- Reader: Hisn al-Muslim recitation (hisnmuslim.com collection)
- Source: Hisnul Muslim 52 — `sheikhhanif/Hisnul_Muslim_Database` `audio/52hm.mp3`
- Source URL: https://github.com/sheikhhanif/Hisnul_Muslim_Database
- License: UNVERIFIED (same Hisn al-Muslim dawah collection as other clips)
- Download date: 2026-09-06
- Size: 141.7 KB
- Status: DOWNLOADED
- Note: Real recitation, not TTS. Matches the dua in `namaz_dualari.json` (Buhârî 831 / Müslim 402 / Hisn al-Muslim 52).

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

- Content: Rabbenâğfir Lî (İbrâhîm 14:41)
- Surah / ayah: 14:41
- Reader: Yasser Al-Dosari (Yasir ed-Devseri)
- Source: EveryAyah `Yasser_Ad-Dussary_128kbps` (same bytes as `quran_014_041.mp3`)
- Source URL: https://everyayah.com/data/Yasser_Ad-Dussary_128kbps/014041.mp3
- License: UNVERIFIED (public recitation CDN; no separate license file found)
- Download date: 2026-09-16
- Size: 130 KB
- Status: DOWNLOADED
- Note: Replaced local/unknown clip with Dosari ayah for voice consistency.

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

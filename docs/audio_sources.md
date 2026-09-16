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
- **Still Fenrir / non-Dosari:** hareke drills (`exercises/`, syllables…), alphabet (Alfathon), asma, namaz duaları (Sübhaneke, Tahiyyat, tekbir, tesbihler…)
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

- Content: Rabbenâ Âtinâ (Bakara 2:201 — full ayah tilavet)
- Surah / ayah: 2:201
- Reader: Yasser Al-Dosari (Yasir ed-Devseri)
- Source: EveryAyah `Yasser_Ad-Dussary_128kbps` (same bytes as `quran_002_201.mp3`)
- Source URL: https://everyayah.com/data/Yasser_Ad-Dussary_128kbps/002201.mp3
- License: UNVERIFIED (public recitation CDN; no separate license file found)
- Download date: 2026-09-16
- Size: 392 KB
- Status: DOWNLOADED
- Note: Replaced Hisn crop with Dosari full-ayah clip for voice consistency. UI Arabic may show only the dua clause; audio includes the ayah opening.

### `assets/audio/duas/quran_002_201.mp3`

- Content: Rabbenâ Âtinâ
- Surah / ayah: 2:201
- Reader: Yasser Al-Dosari (Yasir ed-Devseri)
- Source: EveryAyah `Yasser_Ad-Dussary_128kbps`
- Source URL: https://everyayah.com/data/Yasser_Ad-Dussary_128kbps/002201.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-09-16
- Size: 602.0 KB
- Status: DOWNLOADED

### `assets/audio/duas/quran_002_286.mp3`

- Content: Rabbenâ Lâ Tüâhiznâ
- Surah / ayah: 2:286
- Reader: Yasser Al-Dosari (Yasir ed-Devseri)
- Source: EveryAyah `Yasser_Ad-Dussary_128kbps`
- Source URL: https://everyayah.com/data/Yasser_Ad-Dussary_128kbps/002286.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-09-16
- Size: 1.5 MB
- Status: DOWNLOADED

### `assets/audio/duas/quran_003_008.mp3`

- Content: Rabbenâ Lâ Tüzığ Kulûbenâ
- Surah / ayah: 3:8
- Reader: Yasser Al-Dosari (Yasir ed-Devseri)
- Source: EveryAyah `Yasser_Ad-Dussary_128kbps`
- Source URL: https://everyayah.com/data/Yasser_Ad-Dussary_128kbps/003008.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-09-16
- Size: 340.0 KB
- Status: DOWNLOADED

### `assets/audio/duas/quran_003_016.mp3`

- Content: Rabbenâ İnnenâ Âmennâ
- Surah / ayah: 3:16
- Reader: Yasser Al-Dosari (Yasir ed-Devseri)
- Source: EveryAyah `Yasser_Ad-Dussary_128kbps`
- Source URL: https://everyayah.com/data/Yasser_Ad-Dussary_128kbps/003016.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-09-16
- Size: 464.0 KB
- Status: DOWNLOADED

### `assets/audio/duas/quran_003_053.mp3`

- Content: Rabbenâ Âmennâ
- Surah / ayah: 3:53
- Reader: Yasser Al-Dosari (Yasir ed-Devseri)
- Source: EveryAyah `Yasser_Ad-Dussary_128kbps`
- Source URL: https://everyayah.com/data/Yasser_Ad-Dussary_128kbps/003053.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-09-16
- Size: 368.0 KB
- Status: DOWNLOADED

### `assets/audio/duas/quran_007_023.mp3`

- Content: Rabbenâ Zalemnâ
- Surah / ayah: 7:23
- Reader: Yasser Al-Dosari (Yasir ed-Devseri)
- Source: EveryAyah `Yasser_Ad-Dussary_128kbps`
- Source URL: https://everyayah.com/data/Yasser_Ad-Dussary_128kbps/007023.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-09-16
- Size: 372.0 KB
- Status: DOWNLOADED

### `assets/audio/duas/quran_007_126.mp3`

- Content: Rabbenâ Efrığ Aleynâ
- Surah / ayah: 7:126
- Reader: Yasser Al-Dosari (Yasir ed-Devseri)
- Source: EveryAyah `Yasser_Ad-Dussary_128kbps`
- Source URL: https://everyayah.com/data/Yasser_Ad-Dussary_128kbps/007126.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-09-16
- Size: 590.0 KB
- Status: DOWNLOADED

### `assets/audio/duas/quran_014_040.mp3`

- Content: Rabbi'c'alnî Mukîme's-Salâti
- Surah / ayah: 14:40
- Reader: Yasser Al-Dosari (Yasir ed-Devseri)
- Source: EveryAyah `Yasser_Ad-Dussary_128kbps`
- Source URL: https://everyayah.com/data/Yasser_Ad-Dussary_128kbps/014040.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-09-16
- Size: 376.0 KB
- Status: DOWNLOADED

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

### `assets/audio/duas/quran_018_010.mp3`

- Content: Rabbenâ Âtinâ (Kehf)
- Surah / ayah: 18:10
- Reader: Yasser Al-Dosari (Yasir ed-Devseri)
- Source: EveryAyah `Yasser_Ad-Dussary_128kbps`
- Source URL: https://everyayah.com/data/Yasser_Ad-Dussary_128kbps/018010.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-09-16
- Size: 494.0 KB
- Status: DOWNLOADED

### `assets/audio/duas/quran_020_025.mp3`

- Content: Rabbi'şrah Lî Sadrî
- Surah / ayah: 20:25
- Reader: Yasser Al-Dosari (Yasir ed-Devseri)
- Source: EveryAyah `Yasser_Ad-Dussary_128kbps`
- Source URL: https://everyayah.com/data/Yasser_Ad-Dussary_128kbps/020025.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-09-16
- Size: 110.0 KB
- Status: DOWNLOADED

### `assets/audio/duas/quran_020_114.mp3`

- Content: Rabbi Zıdnî İlmâ
- Surah / ayah: 20:114
- Reader: Yasser Al-Dosari (Yasir ed-Devseri)
- Source: EveryAyah `Yasser_Ad-Dussary_128kbps`
- Source URL: https://everyayah.com/data/Yasser_Ad-Dussary_128kbps/020114.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-09-16
- Size: 484.0 KB
- Status: DOWNLOADED

### `assets/audio/duas/quran_021_083.mp3`

- Content: Rabbi Ennî Messeniye'd-Durru
- Surah / ayah: 21:83
- Reader: Yasser Al-Dosari (Yasir ed-Devseri)
- Source: EveryAyah `Yasser_Ad-Dussary_128kbps`
- Source URL: https://everyayah.com/data/Yasser_Ad-Dussary_128kbps/021083.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-09-16
- Size: 312.0 KB
- Status: DOWNLOADED

### `assets/audio/duas/quran_021_087.mp3`

- Content: Lâ İlâhe İllâ Ente
- Surah / ayah: 21:87
- Reader: Yasser Al-Dosari (Yasir ed-Devseri)
- Source: EveryAyah `Yasser_Ad-Dussary_128kbps`
- Source URL: https://everyayah.com/data/Yasser_Ad-Dussary_128kbps/021087.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-09-16
- Size: 712.0 KB
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

### `assets/audio/duas/quran_023_118.mp3`

- Content: Rabbiğfir Verham
- Surah / ayah: 23:118
- Reader: Yasser Al-Dosari (Yasir ed-Devseri)
- Source: EveryAyah `Yasser_Ad-Dussary_128kbps`
- Source URL: https://everyayah.com/data/Yasser_Ad-Dussary_128kbps/023118.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-09-16
- Size: 164.0 KB
- Status: DOWNLOADED

### `assets/audio/duas/quran_025_074.mp3`

- Content: Rabbenâ Hevvinâ
- Surah / ayah: 25:74
- Reader: Yasser Al-Dosari (Yasir ed-Devseri)
- Source: EveryAyah `Yasser_Ad-Dussary_128kbps`
- Source URL: https://everyayah.com/data/Yasser_Ad-Dussary_128kbps/025074.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-09-16
- Size: 474.0 KB
- Status: DOWNLOADED

### `assets/audio/duas/quran_028_024.mp3`

- Content: Rabbi İnnî Limâ Enzelte
- Surah / ayah: 28:24
- Reader: Yasser Al-Dosari (Yasir ed-Devseri)
- Source: EveryAyah `Yasser_Ad-Dussary_128kbps`
- Source URL: https://everyayah.com/data/Yasser_Ad-Dussary_128kbps/028024.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-09-16
- Size: 512.0 KB
- Status: DOWNLOADED

### `assets/audio/duas/quran_059_010.mp3`

- Content: Rabbenâğfir Lenâ
- Surah / ayah: 59:10
- Reader: Yasser Al-Dosari (Yasir ed-Devseri)
- Source: EveryAyah `Yasser_Ad-Dussary_128kbps`
- Source URL: https://everyayah.com/data/Yasser_Ad-Dussary_128kbps/059010.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-09-16
- Size: 784.0 KB
- Status: DOWNLOADED

### `assets/audio/duas/quran_066_008.mp3`

- Content: Rabbenâ Etmim Lenâ Nûrenâ
- Surah / ayah: 66:8
- Reader: Yasser Al-Dosari (Yasir ed-Devseri)
- Source: EveryAyah `Yasser_Ad-Dussary_128kbps`
- Source URL: https://everyayah.com/data/Yasser_Ad-Dussary_128kbps/066008.mp3
- License: UNVERIFIED (public recitation API; no separate license file found)
- Download date: 2026-09-16
- Size: 1.5 MB
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
- Reader: Wikimedia Commons recording (`iSurrender`)
- Source: [File:Shahadah.ogg](https://commons.wikimedia.org/wiki/File:Shahadah.ogg) MP3 transcode
- Source URL: https://upload.wikimedia.org/wikipedia/commons/transcoded/a/ab/Shahadah.ogg/Shahadah.ogg.mp3
- License: Creative Commons Attribution-Share Alike 3.0 Unported (CC BY-SA 3.0)
- Download date: 2026-09-16
- Size: ~181 KB (~7 s)
- Status: DOWNLOADED
- Note: Real human recitation, not TTS. Spoken form is the common shahada (`…محمدًا رسول الله`). On-screen Diyanet wording uses `عبدُه ورسوله`; both are standard.

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

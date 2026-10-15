# Kur'an Öğren educational audio sources

Updated: 2026-10-15

The Flutter app is **offline**. Runtime never calls TTS APIs.

## Free / clearly licensed replacements

### Alphabet letter names (`assets/audio/quran_learn/alphabet/`)

- **Source:** [Alfathon](https://github.com/kholmatov/alfathon) (`app/src/main/res/raw/*.mp3`)
- **License:** MIT
- **Author:** Erkin Kholmatov
- **Files:** 28 letter-name clips (ا…ي; ح=`ha.mp3`, ه=`hah.mp3`)
- **Attribution:** `assets/audio/quran_learn/alphabet/ATTRIBUTION.md`
- **lam_elif.mp3:** derived from Al Qaida Al Nooraniya (CC BY-SA 4.0) — see `QAMAR_ATTRIBUTION.md`

### Short educational surahs (`assets/audio/quran_learn/surahs/`)

- **Husary Muallim** tilavet (qurancdn reciter 12), same as bundled `assets/audio/quran/`.

### Syllables, marks, shadda, sukun, madd, tanwin, exercises

- **Source:** [Al Qaida Al Nooraniya](https://qamarapps.com/) by Qamar Apps
- **Reciter:** Mufti Mohammed Ghiyas Mohiuddin
- **License:** CC BY-SA 4.0 (derived clips must stay under CC BY-SA 4.0)
- **Attribution:** `assets/audio/quran_learn/QAMAR_ATTRIBUTION.md`, `assets/audio/elifba/ATTRIBUTION.md`
- **Coverage:** hareke triplets, tanwin, madd, 16-letter sukun set, mark names
  (فتحة / كسرة / ضمة / تنوين / سكون / شدة), selected shadda examples

### Words and tajweed examples

- **Single Quran words:** quran.com word-by-word audio (`audio.qurancdn.com/wbw/…`).
  Quran Foundation permission is required for distribution — track separately.
- **Multi-word phrases:** Husary Muallim, cut with MMS forced alignment.
- **Qaida lesson words** (where Elifbâ examples were aligned to Qaida): CC BY-SA 4.0 cuts.

### Intentionally without recording

- Elifbâ shadda syllables (بَّ …) — button hidden
- Sukun for ع غ ف ق ك ل ه ي — no Qaida clip; button hidden
- Daily duas text-only entries

## Manifest

Machine-readable provenance for free alphabet replacements:

`assets/audio/quran_learn/free_audio_manifest.json`

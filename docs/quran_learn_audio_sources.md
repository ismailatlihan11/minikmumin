# Kur'an Öğren educational audio sources

Updated: 2026-09-13

The Flutter app is **offline**. Runtime never calls TTS APIs.

## Free / clearly licensed replacements

### Alphabet letter names (`assets/audio/quran_learn/alphabet/`)

- **Source:** [Alfathon](https://github.com/kholmatov/alfathon) (`app/src/main/res/raw/*.mp3`)
- **License:** MIT
- **Author:** Erkin Kholmatov
- **Files replaced:** 28 letter-name clips (ا…ي; ح=`ha.mp3`, ه=`hah.mp3`)
- **Attribution file:** `assets/audio/quran_learn/alphabet/ATTRIBUTION.md`
- **Not replaced:** `lam_elif.mp3` (no matching free clip in Alfathon) — still previous TTS if present

Import:

```bash
python3 scripts/fetch_free_educational_audio.py --force
```

### Short educational surahs (`assets/audio/quran_learn/surahs/`)

- Replaced Fenrir cartoon TTS with the same **Husary Muallim** tilavet already
  bundled under `assets/audio/quran/` (12 files).
- License status: public recitation API / Quran.com — see `docs/audio_sources.md`
  (not independently verified as commercial royalty-free).

## Still Google Cloud TTS (Fenrir cartoon)

No matching free recording packs were found for these educational syllables yet:

- `exercises/` (harekeli heceler: بَ طَ …)
- `syllables/`, `sukun/`, `shadda/`, `madd/`, `combine/`, `letter_combinations/`
- `harakat/`, `tanwin/` mark names
- `tajweed/` example clips
- `lam_elif.mp3` (alphabet ligature)
- Prayer / dua / asma Fenrir packs under `assets/audio/{prayer,duas,asma}/`

Those remain synthetic until a CC/MIT/PD pack covering hareke drills is sourced.

## Manifest

Machine-readable provenance for the free replacements:

`assets/audio/quran_learn/free_audio_manifest.json`

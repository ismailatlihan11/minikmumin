#!/usr/bin/env python3
"""Replace Google TTS clips with clearly licensed free recordings where possible.

Alphabet letter names:
  Source: https://github.com/kholmatov/alfathon (MIT)
  Local clone expected at --alfathon-raw, or auto-clone.

Short educational surahs under quran_learn/surahs/:
  Replaced with bundled Husary Muallim tilavet from assets/audio/quran/
  (same files already documented in docs/audio_sources.md).

Remaining haraka / syllable / exercise / asma / dua clips stay TTS until a
matching free recording pack is found — those are not silently invented.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ALPHABET_DIR = ROOT / "assets" / "audio" / "quran_learn" / "alphabet"
SURAH_LEARN_DIR = ROOT / "assets" / "audio" / "quran_learn" / "surahs"
SURAH_QURAN_DIR = ROOT / "assets" / "audio" / "quran"
DOCS = ROOT / "docs" / "quran_learn_audio_sources.md"
MANIFEST = ROOT / "assets" / "audio" / "quran_learn" / "free_audio_manifest.json"
ATTRIBUTION = ALPHABET_DIR / "ATTRIBUTION.md"

# Alfathon raw filename -> our alphabet stem
ALFATHON_MAP = {
    "alif.mp3": "elif",
    "ba.mp3": "ba",
    "taa.mp3": "ta",
    "tha.mp3": "tha",
    "jeem.mp3": "jim",
    "haa.mp3": "ha",  # ح
    "khaa.mp3": "kha",
    "dal.mp3": "dal",
    "dhal.mp3": "dhal",
    "raa.mp3": "ra",
    "jaa.mp3": "zay",  # ز
    "seen.mp3": "sin",
    "sheen.mp3": "shin",
    "saad.mp3": "sad",
    "dhaad.mp3": "dad",
    "toa.mp3": "ta_heavy",
    "dhaa.mp3": "za_heavy",
    "ain.mp3": "ayn",
    "ghain.mp3": "ghayn",
    "faa.mp3": "fa",
    "qaaf.mp3": "qaf",
    "kaaf.mp3": "kaf",
    "laam.mp3": "lam",
    "meem.mp3": "mim",
    "noon.mp3": "nun",
    "ha.mp3": "hah",  # ه
    "waw.mp3": "waw",
    "yaa.mp3": "ya",
}

SURAH_NUMBERS = (1, 103, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114)


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 16), b""):
            h.update(chunk)
    return h.hexdigest()


def ensure_alfathon(raw_dir: Path | None) -> Path:
    if raw_dir and raw_dir.is_dir():
        return raw_dir
    clone = Path("/tmp/audio_src/alfathon")
    raw = clone / "app" / "src" / "main" / "res" / "raw"
    if raw.is_dir():
        return raw
    clone.parent.mkdir(parents=True, exist_ok=True)
    if clone.exists():
        shutil.rmtree(clone)
    subprocess.run(
        ["git", "clone", "--depth", "1", "https://github.com/kholmatov/alfathon.git", str(clone)],
        check=True,
    )
    if not raw.is_dir():
        raise SystemExit(f"Alfathon raw audio missing at {raw}")
    return raw


def import_alphabet(raw: Path, *, force: bool) -> list[dict]:
    ALPHABET_DIR.mkdir(parents=True, exist_ok=True)
    items: list[dict] = []
    for src_name, stem in ALFATHON_MAP.items():
        src = raw / src_name
        dest = ALPHABET_DIR / f"{stem}.mp3"
        if not src.is_file():
            print(f"MISSING {src_name}", file=sys.stderr)
            continue
        if dest.exists() and not force:
            # Always overwrite TTS when force or when replacing free set.
            pass
        shutil.copy2(src, dest)
        items.append(
            {
                "id": stem,
                "category": "alphabet",
                "path": f"assets/audio/quran_learn/alphabet/{stem}.mp3",
                "source": "alfathon",
                "source_file": src_name,
                "license": "MIT",
                "source_url": "https://github.com/kholmatov/alfathon",
                "sha256": sha256(dest),
                "bytes": dest.stat().st_size,
            }
        )
        print(f"alphabet  {stem:12s} <- {src_name}")
    ATTRIBUTION.write_text(
        "\n".join(
            [
                "# Alphabet audio attribution",
                "",
                "Letter-name clips in this folder (except any file listed as TTS in",
                "`free_audio_manifest.json`) come from **Alfathon**:",
                "",
                "- Project: https://github.com/kholmatov/alfathon",
                "- Author: Erkin Kholmatov",
                "- License: MIT (see repository LICENSE)",
                "",
                "Copyright (c) 2025 Erkin Kholmatov",
                "",
                "Permission is hereby granted, free of charge, to any person obtaining a copy",
                'of this software and associated documentation files (the "Software"), to deal',
                "in the Software without restriction, including without limitation the rights",
                "to use, copy, modify, merge, publish, distribute, sublicense, and/or sell",
                "copies of the Software, and to permit persons to whom the Software is",
                "furnished to do so, subject to the following conditions:",
                "",
                "The above copyright notice and this permission notice shall be included in all",
                "copies or substantial portions of the Software.",
                "",
            ]
        ),
        encoding="utf-8",
    )
    return items


def import_surahs(*, force: bool) -> list[dict]:
    SURAH_LEARN_DIR.mkdir(parents=True, exist_ok=True)
    items: list[dict] = []
    for n in SURAH_NUMBERS:
        name = f"surah_{n:03d}.mp3"
        src = SURAH_QURAN_DIR / name
        dest = SURAH_LEARN_DIR / name
        if not src.is_file():
            print(f"MISSING husary {name}", file=sys.stderr)
            continue
        shutil.copy2(src, dest)
        items.append(
            {
                "id": f"surah_{n:03d}",
                "category": "surah",
                "path": f"assets/audio/quran_learn/surahs/{name}",
                "source": "husary_muallim",
                "license": "UNVERIFIED (public recitation API / Quran.com)",
                "source_url": "https://quran.com",
                "reader": "Mahmoud Khalil Al-Husary (Muallim)",
                "sha256": sha256(dest),
                "bytes": dest.stat().st_size,
            }
        )
        print(f"surah     {name}")
    return items


def write_docs(alphabet_n: int, surah_n: int) -> None:
    stamp = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    text = f"""# Kur'an Öğren educational audio sources

Updated: {stamp}

The Flutter app is **offline**. Runtime never calls TTS APIs.

## Free / clearly licensed replacements

### Alphabet letter names (`assets/audio/quran_learn/alphabet/`)

- **Source:** [Alfathon](https://github.com/kholmatov/alfathon) (`app/src/main/res/raw/*.mp3`)
- **License:** MIT
- **Author:** Erkin Kholmatov
- **Files replaced:** {alphabet_n} letter-name clips (ا…ي; ح=`ha.mp3`, ه=`hah.mp3`)
- **Attribution file:** `assets/audio/quran_learn/alphabet/ATTRIBUTION.md`
- **Not replaced:** `lam_elif.mp3` (no matching free clip in Alfathon) — still previous TTS if present

Import:

```bash
python3 scripts/fetch_free_educational_audio.py --force
```

### Short educational surahs (`assets/audio/quran_learn/surahs/`)

- Replaced Fenrir cartoon TTS with the same **Husary Muallim** tilavet already
  bundled under `assets/audio/quran/` ({surah_n} files).
- License status: public recitation API / Quran.com — see `docs/audio_sources.md`
  (not independently verified as commercial royalty-free).

## Still Google Cloud TTS (Fenrir cartoon)

No matching free recording packs were found for these educational syllables yet:

- `exercises/` (harekeli heceler: بَ طَ …)
- `syllables/`, `sukun/`, `shadda/`, `madd/`, `combine/`, `letter_combinations/`
- `harakat/`, `tanwin/` mark names
- `tajweed/` example clips
- `lam_elif.mp3` (alphabet ligature)
- Prayer / dua / asma Fenrir packs under `assets/audio/{{prayer,duas,asma}}/`

Those remain synthetic until a CC/MIT/PD pack covering hareke drills is sourced.

## Manifest

Machine-readable provenance for the free replacements:

`assets/audio/quran_learn/free_audio_manifest.json`
"""
    DOCS.write_text(text, encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--alfathon-raw",
        type=Path,
        help="Path to Alfathon res/raw (default: clone to /tmp/audio_src/alfathon)",
    )
    parser.add_argument("--force", action="store_true", help="Overwrite existing files")
    parser.add_argument("--alphabet-only", action="store_true")
    parser.add_argument("--surahs-only", action="store_true")
    args = parser.parse_args()

    alphabet_items: list[dict] = []
    surah_items: list[dict] = []
    if not args.surahs_only:
        raw = ensure_alfathon(args.alfathon_raw)
        alphabet_items = import_alphabet(raw, force=args.force or True)
    if not args.alphabet_only:
        surah_items = import_surahs(force=args.force or True)

    manifest = {
        "module": "quran_learn",
        "kind": "free_educational_recordings",
        "updated_at": datetime.now(timezone.utc).isoformat(),
        "alphabet_source": {
            "name": "Alfathon",
            "url": "https://github.com/kholmatov/alfathon",
            "license": "MIT",
        },
        "surah_source": {
            "name": "Husary Muallim via bundled assets/audio/quran",
            "license": "UNVERIFIED (public recitation API)",
        },
        "items": alphabet_items + surah_items,
        "still_tts": [
            "exercises",
            "syllables",
            "sukun",
            "shadda",
            "madd",
            "combine",
            "letter_combinations",
            "harakat",
            "tanwin",
            "tajweed",
            "lam_elif",
            "prayer",
            "duas",
            "asma",
        ],
    }
    MANIFEST.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    write_docs(len(alphabet_items), len(surah_items))
    print(
        f"\ndone: alphabet={len(alphabet_items)} surahs={len(surah_items)} "
        f"manifest={MANIFEST.relative_to(ROOT)}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

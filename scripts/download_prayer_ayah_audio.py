#!/usr/bin/env python3
"""Download per-ayah Yasir ed-Devseri clips for namaz sureleri (ezber sync).

Source (same as existing dua ayah clips in docs/audio_sources.md):
  https://mirrors.quranicaudio.com/everyayah/Yasser_Ad-Dussary_128kbps/{SSS}{AAA}.mp3

Writes: assets/audio/quran/ayahs/{SSS}_{AAA}.mp3
"""

from __future__ import annotations

import json
import sys
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "audio" / "quran" / "ayahs"
JSON = ROOT / "assets" / "data" / "namaz_dualari.json"
BASE = "https://mirrors.quranicaudio.com/everyayah/Yasser_Ad-Dussary_128kbps"


def surahs_from_json() -> list[tuple[int, list[int]]]:
    data = json.loads(JSON.read_text(encoding="utf-8"))
    out: list[tuple[int, list[int]]] = []
    for item in data.get("items", []):
        number = item.get("surahNumber")
        verses = item.get("verses") or []
        if not number or not verses:
            continue
        ayahs = [int(v["ayahNo"]) for v in verses if "ayahNo" in v]
        out.append((int(number), ayahs))
    return out


def download(surah: int, ayah: int) -> Path | None:
    code = f"{surah:03d}{ayah:03d}"
    dest = OUT / f"{surah:03d}_{ayah:03d}.mp3"
    if dest.exists() and dest.stat().st_size > 1000:
        print(f"skip  {dest.name}")
        return dest
    url = f"{BASE}/{code}.mp3"
    dest.parent.mkdir(parents=True, exist_ok=True)
    try:
        with urllib.request.urlopen(url, timeout=60) as resp:
            data = resp.read()
    except Exception as exc:  # noqa: BLE001
        print(f"FAIL  {code}: {exc}", file=sys.stderr)
        return None
    if len(data) < 1000:
        print(f"FAIL  {code}: too small ({len(data)})", file=sys.stderr)
        return None
    dest.write_bytes(data)
    print(f"ok    {dest.name} ({len(data)} bytes)")
    return dest


def main() -> int:
    packs = surahs_from_json()
    if not packs:
        print("no surahs in namaz_dualari.json", file=sys.stderr)
        return 1
    ok = 0
    fail = 0
    for surah, ayahs in packs:
        for ayah in ayahs:
            if download(surah, ayah):
                ok += 1
            else:
                fail += 1
    print(f"\ndone ok={ok} fail={fail} dir={OUT}")
    return 1 if fail else 0


if __name__ == "__main__":
    raise SystemExit(main())

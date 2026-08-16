#!/usr/bin/env python3
"""Validate bundled religious JSON without rewriting source files."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "assets" / "data"

quran_path = DATA / "kuran.json"
hadith_path = DATA / "hadis.json"

q = json.loads(quran_path.read_text(encoding="utf-8"))
h = json.loads(hadith_path.read_text(encoding="utf-8"))
ayahs = q.get("ayet", [])
hadiths = h if isinstance(h, list) else h.get("items", [])

assert len(ayahs) == len({x["ayet_id"] for x in ayahs}), "duplicate ayet_id"
assert len(hadiths) == len({x["hadith_id"] for x in hadiths}), "duplicate hadith_id"
assert all(x.get("metin", {}).get("arapca") for x in ayahs), "missing Arabic ayah"
assert all(x.get("metin", {}).get("meal") is not None for x in ayahs), "missing meal"
assert all(x.get("arabic") is not None and x.get("turkish") is not None for x in hadiths)

print(f"Quran: {len(ayahs)} ayet / {len({x['sure_id'] for x in ayahs})} sure")
print(f"Hadith: {len(hadiths)} kayıt")
print("CONTENT VALIDATION OK")

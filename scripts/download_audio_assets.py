#!/usr/bin/env python3
"""Download licensed Quran recitation MP3s for Minik Mümin.

Quran surahs and Quran-ayah duas are fetched from official APIs.
Prayer / non-Quran phrases are never downloaded from the internet.
"""

from __future__ import annotations

import argparse
import datetime as dt
import json
import sys
import time
import urllib.error
import urllib.request
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
TIMEOUT = 45
RETRIES = 3
USER_AGENT = "MinikMuminAudio/1.0 (educational; minik_kalpler)"
TODAY = dt.date.today().isoformat()

PRIMARY_NEEDLES = (
    "mahmoud al-husary (with children)",
    "mahmoud khalil al-husary (with children)",
    "husary (with children)",
    "hussary (with children)",
    "al-husary (with children)",
)
FALLBACK_NEEDLES = (
    "al-hussayni al-'azazy (with children)",
    "al-husayni al-azazi (with children)",
    "alhusayni al-azazi (with children)",
    "husayni al-azazi (with children)",
    "al-azazi (with children)",
)
CHILD_STYLE_NEEDLES = (
    "with children",
    "children",
    "muallim",
    "mo'lim",
    "mo lim",
    "المعلم",
    "أطفال",
)

QURAN_SURAHS = [
    (1, "assets/audio/quran/surah_001.mp3", "Fâtiha"),
    (108, "assets/audio/quran/surah_108.mp3", "Kevser"),
    (112, "assets/audio/quran/surah_112.mp3", "İhlâs"),
    (103, "assets/audio/quran/surah_103.mp3", "Asr"),
    (114, "assets/audio/quran/surah_114.mp3", "Nâs"),
    (113, "assets/audio/quran/surah_113.mp3", "Felak"),
    (109, "assets/audio/quran/surah_109.mp3", "Kâfirûn"),
    (110, "assets/audio/quran/surah_110.mp3", "Nasr"),
    (111, "assets/audio/quran/surah_111.mp3", "Tebbet"),
    (107, "assets/audio/quran/surah_107.mp3", "Mâûn"),
    (105, "assets/audio/quran/surah_105.mp3", "Fîl"),
    (106, "assets/audio/quran/surah_106.mp3", "Kureyş"),
]

AYAH_DUAS = [
    ("assets/audio/duas/rabbena_atina.mp3", "Rabbenâ Âtinâ (namaz)", 2, 201),
    ("assets/audio/duas/quran_002_201.mp3", "Rabbenâ Âtinâ", 2, 201),
    ("assets/audio/duas/quran_002_286.mp3", "Rabbenâ Lâ Tüâhiznâ", 2, 286),
    ("assets/audio/duas/quran_003_008.mp3", "Rabbenâ Lâ Tüzığ Kulûbenâ", 3, 8),
    ("assets/audio/duas/quran_003_016.mp3", "Rabbenâ İnnenâ Âmennâ", 3, 16),
    ("assets/audio/duas/quran_003_053.mp3", "Rabbenâ Âmennâ", 3, 53),
    ("assets/audio/duas/quran_007_023.mp3", "Rabbenâ Zalemnâ", 7, 23),
    ("assets/audio/duas/quran_007_126.mp3", "Rabbenâ Efrığ Aleynâ", 7, 126),
    ("assets/audio/duas/quran_014_040.mp3", "Rabbi'c'alnî Mukîme's-Salâti", 14, 40),
    ("assets/audio/duas/quran_014_041.mp3", "Rabbenâğfir Lî", 14, 41),
    ("assets/audio/duas/quran_018_010.mp3", "Rabbenâ Âtinâ (Kehf)", 18, 10),
    ("assets/audio/duas/quran_020_025.mp3", "Rabbi'şrah Lî Sadrî", 20, 25),
    ("assets/audio/duas/quran_020_114.mp3", "Rabbi Zıdnî İlmâ", 20, 114),
    ("assets/audio/duas/quran_021_083.mp3", "Rabbi Ennî Messeniye'd-Durru", 21, 83),
    ("assets/audio/duas/quran_021_087.mp3", "Lâ İlâhe İllâ Ente", 21, 87),
    ("assets/audio/duas/quran_023_097.mp3", "Rabbi Eûzü Bike", 23, 97),
    ("assets/audio/duas/quran_023_118.mp3", "Rabbiğfir Verham", 23, 118),
    ("assets/audio/duas/quran_025_074.mp3", "Rabbenâ Hevvinâ", 25, 74),
    ("assets/audio/duas/quran_028_024.mp3", "Rabbi İnnî Limâ Enzelte", 28, 24),
    ("assets/audio/duas/quran_059_010.mp3", "Rabbenâğfir Lenâ", 59, 10),
    ("assets/audio/duas/quran_066_008.mp3", "Rabbenâ Etmim Lenâ Nûrenâ", 66, 8),
]

PRAYER_FILES = [
    ("assets/audio/prayer/besmele.mp3", "Besmele"),
    ("assets/audio/prayer/hamdele.mp3", "Hamdele"),
    ("assets/audio/prayer/kelime_i_tevhid.mp3", "Kelime-i Tevhid"),
    ("assets/audio/prayer/kelime_i_sehadet.mp3", "Kelime-i Şehadet"),
    ("assets/audio/prayer/subhaneke.mp3", "Sübhaneke"),
    ("assets/audio/prayer/tahiyyat.mp3", "Et-Tahiyyâtü"),
    ("assets/audio/prayer/allahumme_salli.mp3", "Allahümme Salli"),
    ("assets/audio/prayer/allahumme_barik.mp3", "Allahümme Bârik"),
    ("assets/audio/prayer/rabbena_gfirli.mp3", "Rabbenâğfir Lî"),
    ("assets/audio/prayer/iftitah_tekbir.mp3", "İftitah Tekbiri"),
    ("assets/audio/prayer/ruku_tesbihi.mp3", "Rükû Tesbihi"),
    ("assets/audio/prayer/rukudan_dogrulurken.mp3", "Rükûdan Doğrulma"),
    ("assets/audio/prayer/sujud_tesbihi.mp3", "Secde Tesbihi"),
]


@dataclass
class ReciterChoice:
    name: str
    source: str
    kind: str  # mp3quran | quran_com | alquran_cloud
    reciter_id: str = ""
    server: str = ""
    surah_list: set[int] = field(default_factory=set)
    extra: dict[str, Any] = field(default_factory=dict)


@dataclass
class Row:
    path: str
    title: str
    surah: str = "—"
    reader: str = "—"
    source: str = "—"
    url: str = "—"
    license_info: str = "—"
    status: str = "FAILED"
    size: str = "—"
    note: str = ""


def log(msg: str) -> None:
    print(msg, flush=True)


def http_json(url: str) -> Any:
    last_error: Exception | None = None
    for attempt in range(1, RETRIES + 1):
        try:
            req = urllib.request.Request(
                url,
                headers={"User-Agent": USER_AGENT, "Accept": "application/json"},
            )
            with urllib.request.urlopen(req, timeout=TIMEOUT) as resp:
                if resp.status != 200:
                    raise RuntimeError(f"HTTP {resp.status} for {url}")
                return json.loads(resp.read().decode("utf-8"))
        except urllib.error.URLError as exc:
            last_error = exc
            reason = getattr(exc, "reason", exc)
            if "nodename nor servname" in str(reason) or "Name or service not known" in str(reason):
                raise RuntimeError(
                    "İnternet bağlantısı yok veya DNS çözülemedi. "
                    "Bağlantıyı kontrol edip scripti tekrar çalıştırın."
                ) from exc
            log(f"  API retry {attempt}/{RETRIES}: {url} ({reason})")
            time.sleep(attempt)
        except Exception as exc:  # noqa: BLE001
            last_error = exc
            log(f"  API retry {attempt}/{RETRIES}: {url} ({exc})")
            time.sleep(attempt)
    raise RuntimeError(f"API isteği başarısız: {url}") from last_error


def normalize_url(url: str) -> str:
    url = (url or "").strip()
    if url.startswith("//"):
        return "https:" + url
    return url


def _norm(text: str) -> str:
    return (
        (text or "")
        .lower()
        .replace("’", "'")
        .replace("`", "'")
        .replace("  ", " ")
        .strip()
    )


def _blob(*parts: str) -> str:
    return " ".join(_norm(part) for part in parts if part)


def _has_child_style(text: str) -> bool:
    return any(needle in text for needle in CHILD_STYLE_NEEDLES)


def _is_husary(text: str) -> bool:
    return "husary" in text or "hussary" in text or "حصري" in text


def _is_azazi(text: str) -> bool:
    return any(token in text for token in ("azazi", "azazy", "عزازي", "husayni", "hussayni", "حسين"))


def parse_surah_list(raw: Any) -> set[int]:
    if not raw:
        return set()
    if isinstance(raw, list):
        return {int(item) for item in raw}
    numbers: set[int] = set()
    for part in str(raw).split(","):
        part = part.strip()
        if part.isdigit():
            numbers.add(int(part))
    return numbers


def find_mp3quran_reciter(*, primary: bool) -> ReciterChoice | None:
    data = http_json("https://www.mp3quran.net/api/v3/reciters?language=eng")
    reciters = data.get("reciters") or []
    ranked: list[tuple[int, ReciterChoice]] = []
    for rec in reciters:
        name = rec.get("name") or ""
        for moshaf in rec.get("moshaf") or []:
            moshaf_name = moshaf.get("name") or ""
            blob = _blob(name, moshaf_name)
            score = 0
            if primary:
                if any(needle in blob for needle in PRIMARY_NEEDLES):
                    score = 300
                elif _is_husary(blob) and _has_child_style(blob):
                    score = 250
            else:
                if any(needle in blob for needle in FALLBACK_NEEDLES):
                    score = 200
                elif _is_azazi(blob) and _has_child_style(blob):
                    score = 180
            if score == 0:
                continue
            surahs = parse_surah_list(moshaf.get("surah_list"))
            if len(surahs) >= 100:
                score += 10
            ranked.append(
                (
                    score,
                    ReciterChoice(
                        name=f"{name} / {moshaf_name}".strip(" /"),
                        source="MP3Quran API v3",
                        kind="mp3quran",
                        reciter_id=str(rec.get("id")),
                        server=str(moshaf.get("server") or ""),
                        surah_list=surahs,
                        extra={"moshaf_id": moshaf.get("id")},
                    ),
                )
            )
    if not ranked:
        return None
    ranked.sort(key=lambda item: item[0], reverse=True)
    return ranked[0][1]


def find_quran_com_reciter(*, primary: bool) -> ReciterChoice | None:
    data = http_json("https://api.quran.com/api/v4/resources/recitations")
    recitations = data.get("recitations") or []
    ranked: list[tuple[int, ReciterChoice]] = []
    for rec in recitations:
        name = rec.get("reciter_name") or ""
        style = rec.get("style") or ""
        translated = ((rec.get("translated_name") or {}).get("name")) or ""
        blob = _blob(name, style, translated)
        score = 0
        if primary:
            if any(needle in blob for needle in PRIMARY_NEEDLES):
                score = 300
            elif _is_husary(blob) and _has_child_style(blob):
                score = 260
        else:
            if any(needle in blob for needle in FALLBACK_NEEDLES):
                score = 200
            elif _is_azazi(blob) and _has_child_style(blob):
                score = 180
        if score == 0:
            continue
        ranked.append(
            (
                score,
                ReciterChoice(
                    name=f"{name}" + (f" ({style})" if style else ""),
                    source="Quran.com API v4",
                    kind="quran_com",
                    reciter_id=str(rec.get("id")),
                    extra={"style": style},
                ),
            )
        )
    if not ranked:
        return None
    ranked.sort(key=lambda item: item[0], reverse=True)
    return ranked[0][1]


def find_alquran_cloud_reciter(*, primary: bool) -> ReciterChoice | None:
    data = http_json("https://api.alquran.cloud/v1/edition?format=audio")
    editions = data.get("data") or []
    ranked: list[tuple[int, ReciterChoice]] = []
    for rec in editions:
        ident = rec.get("identifier") or ""
        name = rec.get("englishName") or rec.get("name") or ident
        blob = _blob(ident, name, rec.get("name") or "")
        score = 0
        if primary:
            if any(needle in blob for needle in PRIMARY_NEEDLES):
                score = 300
            elif _is_husary(blob) and _has_child_style(blob):
                score = 250
        else:
            if any(needle in blob for needle in FALLBACK_NEEDLES) or (
                _is_azazi(blob) and _has_child_style(blob)
            ):
                score = 200
        if score == 0:
            continue
        ranked.append(
            (
                score,
                ReciterChoice(
                    name=str(name),
                    source="AlQuran.cloud API",
                    kind="alquran_cloud",
                    reciter_id=str(ident),
                    extra={"type": rec.get("type")},
                ),
            )
        )
    if not ranked:
        return None
    ranked.sort(key=lambda item: item[0], reverse=True)
    return ranked[0][1]


def choose_reciter() -> ReciterChoice:
    log("1) MP3Quran: Mahmoud Al-Husary (with Children) aranıyor…")
    choice = find_mp3quran_reciter(primary=True)
    if choice:
        log(f"MP3Quran birincil eşleşme: {choice.name}")
        return choice
    log("2) Quran.com: Husary Muallim / with Children aranıyor…")
    choice = find_quran_com_reciter(primary=True)
    if choice:
        log(f"Quran.com birincil eşleşme: {choice.name} (id={choice.reciter_id})")
        return choice
    log("3) AlQuran.cloud: Husary with Children aranıyor…")
    choice = find_alquran_cloud_reciter(primary=True)
    if choice:
        log(f"AlQuran.cloud birincil eşleşme: {choice.name}")
        return choice
    log("4) Yedek: Al-Hussayni Al-'Azazy (with Children) aranıyor…")
    for finder in (
        lambda: find_mp3quran_reciter(primary=False),
        lambda: find_quran_com_reciter(primary=False),
        lambda: find_alquran_cloud_reciter(primary=False),
    ):
        choice = finder()
        if choice:
            log(f"Yedek eşleşme: {choice.name} [{choice.source}]")
            return choice
    raise RuntimeError(
        "Öncelikli okuyucu (Husary with Children) ve yedek (Azazi with Children) "
        "hiçbir resmi API'de bulunamadı."
    )


def surah_url(choice: ReciterChoice, surah: int) -> str | None:
    if choice.kind == "mp3quran":
        if choice.surah_list and surah not in choice.surah_list:
            return None
        server = choice.server.rstrip("/") + "/"
        return f"{server}{surah:03d}.mp3"
    if choice.kind == "quran_com":
        data = http_json(
            f"https://api.quran.com/api/v4/chapter_recitations/{choice.reciter_id}/{surah}"
        )
        audio = (data.get("audio_file") or {}).get("audio_url")
        return normalize_url(audio) if audio else None
    if choice.kind == "alquran_cloud":
        data = http_json(
            f"https://api.alquran.cloud/v1/surah/{surah}/{choice.reciter_id}"
        )
        audio = (data.get("data") or {}).get("audio")
        return normalize_url(audio) if audio else None
    return None


def ayah_url(choice: ReciterChoice, surah: int, ayah: int) -> str | None:
    if choice.kind == "quran_com":
        data = http_json(
            f"https://api.quran.com/api/v4/recitations/{choice.reciter_id}/by_ayah/{surah}:{ayah}"
        )
        files = data.get("audio_files") or []
        if not files:
            return None
        return normalize_url(files[0].get("url") or "")
    if choice.kind == "alquran_cloud":
        edition_type = str(choice.extra.get("type") or "")
        if edition_type != "versebyverse":
            return None
        data = http_json(
            f"https://api.alquran.cloud/v1/ayah/{surah}:{ayah}/{choice.reciter_id}"
        )
        audio = (data.get("data") or {}).get("audio")
        return normalize_url(audio) if audio else None
    return None


def looks_like_audio(header: bytes, content_type: str) -> bool:
    ctype = (content_type or "").lower()
    if any(token in ctype for token in ("audio/mpeg", "audio/mp3", "audio/mpeg3", "audio/x-mpeg")):
        return True
    if header.startswith(b"ID3") or header[:2] in (b"\xff\xfb", b"\xff\xf3", b"\xff\xf2", b"\xff\xfa"):
        return True
    if "octet-stream" in ctype and (header.startswith(b"ID3") or header[:1] == b"\xff"):
        return True
    return False


def download_mp3(url: str, dest: Path) -> int:
    dest.parent.mkdir(parents=True, exist_ok=True)
    last_error: Exception | None = None
    for attempt in range(1, RETRIES + 1):
        part = dest.with_suffix(dest.suffix + ".part")
        try:
            if part.exists():
                part.unlink()
            req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
            with urllib.request.urlopen(req, timeout=TIMEOUT) as resp:
                if resp.status != 200:
                    raise RuntimeError(f"HTTP {resp.status}")
                content_type = resp.headers.get("Content-Type") or ""
                first = resp.read(16)
                if not looks_like_audio(first, content_type):
                    raise RuntimeError(f"Beklenmeyen içerik tipi: {content_type!r}")
                with part.open("wb") as handle:
                    handle.write(first)
                    while True:
                        chunk = resp.read(64 * 1024)
                        if not chunk:
                            break
                        handle.write(chunk)
            size = part.stat().st_size
            if size <= 0:
                part.unlink(missing_ok=True)
                raise RuntimeError("0 byte dosya")
            part.replace(dest)
            return size
        except urllib.error.URLError as exc:
            last_error = exc
            reason = getattr(exc, "reason", exc)
            if "nodename nor servname" in str(reason) or "Name or service not known" in str(reason):
                raise RuntimeError(
                    "İnternet bağlantısı yok veya DNS çözülemedi."
                ) from exc
            log(f"  indirme retry {attempt}/{RETRIES}: {exc}")
            time.sleep(attempt)
        except Exception as exc:  # noqa: BLE001
            last_error = exc
            log(f"  indirme retry {attempt}/{RETRIES}: {exc}")
            time.sleep(attempt)
        finally:
            if part.exists() and not dest.exists():
                part.unlink(missing_ok=True)
    raise RuntimeError(f"İndirme başarısız: {url}") from last_error


def human_size(num: int) -> str:
    value = float(num)
    for unit in ("B", "KB", "MB"):
        if value < 1024 or unit == "MB":
            return f"{value:.1f} {unit}" if unit != "B" else f"{int(value)} B"
        value /= 1024
    return f"{num} B"


def existing_row(path: str, title: str, surah: str = "—") -> Row:
    dest = ROOT / path
    if dest.exists() and dest.stat().st_size > 0:
        return Row(
            path=path,
            title=title,
            surah=surah,
            reader="unknown (pre-existing file)",
            source="local asset (license not verified)",
            url="—",
            license_info="UNVERIFIED",
            status="ALREADY EXISTED",
            size=human_size(dest.stat().st_size),
            note="Existing file kept. License could not be verified.",
        )
    return Row(
        path=path,
        title=title,
        surah=surah,
        reader="—",
        source="not downloaded",
        url="—",
        license_info="UNVERIFIED",
        status="MANUAL_REQUIRED",
        note="No verified license. Do not download from random websites or YouTube.",
    )


def save_rows(rows: list[Row], reciter: ReciterChoice | None) -> None:
    docs = ROOT / "docs"
    docs.mkdir(parents=True, exist_ok=True)
    lines = [
        "# Audio sources",
        "",
        f"Generated: {TODAY}",
        "",
        "Quran recitation files are downloaded from official APIs.",
        "Prayer / non-Quran phrases are **not** fetched from the internet.",
        "",
    ]
    if reciter:
        lines += [
            "## Selected reciter",
            "",
            f"- Name: {reciter.name}",
            f"- Source: {reciter.source}",
            f"- API kind: {reciter.kind}",
            f"- Reciter id (from API result, not hard-coded in advance): `{reciter.reciter_id}`",
            "",
            "License: public recitation API. A separate commercial license document was not independently verified.",
            "",
        ]
    lines += [
        "## Files",
        "",
    ]
    for row in rows:
        lines += [
            f"### `{row.path}`",
            "",
            f"- Content: {row.title}",
            f"- Surah / ayah: {row.surah}",
            f"- Reader: {row.reader}",
            f"- Source: {row.source}",
            f"- Source URL: {row.url}",
            f"- License: {row.license_info}",
            f"- Download date: {TODAY}",
            f"- Size: {row.size}",
            f"- Status: {row.status}",
        ]
        if row.note:
            lines.append(f"- Note: {row.note}")
        lines.append("")
    (docs / "audio_sources.md").write_text("\n".join(lines), encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--skip-existing",
        action="store_true",
        default=True,
        help="Skip files that already exist (default).",
    )
    parser.add_argument(
        "--replace-quran",
        action="store_true",
        help="Replace existing Quran surah/ayah MP3s with the API reciter.",
    )
    args = parser.parse_args()
    skip_existing = args.skip_existing and not args.replace_quran

    rows: list[Row] = []
    try:
        reciter = choose_reciter()
    except Exception as exc:  # noqa: BLE001
        log(str(exc))
        reciter = None
        for surah, path, title in QURAN_SURAHS:
            rows.append(existing_row(path, title, f"Surah {surah:03d}"))
            rows[-1].status = "FAILED"
            rows[-1].note = str(exc)
        for path, title, surah, ayah in AYAH_DUAS:
            rows.append(existing_row(path, title, f"{surah}:{ayah}"))
            rows[-1].status = "FAILED"
            rows[-1].note = str(exc)
        for path, title in PRAYER_FILES:
            rows.append(existing_row(path, title))
        save_rows(rows, None)
        print_summary(rows)
        return 1

    log(f"Okuyucu: {reciter.name} [{reciter.source}]")

    for surah, path, title in QURAN_SURAHS:
        dest = ROOT / path
        log(f"Sure {surah:03d} → {path}")
        if skip_existing and dest.exists() and dest.stat().st_size > 0:
            row = existing_row(path, title, f"Surah {surah:03d}")
            row.status = "ALREADY EXISTED"
            rows.append(row)
            log(f"  skip existing ({row.size})")
            continue
        try:
            url = surah_url(reciter, surah)
            if not url:
                rows.append(
                    Row(
                        path=path,
                        title=title,
                        surah=f"Surah {surah:03d}",
                        reader=reciter.name,
                        source=reciter.source,
                        license_info="UNVERIFIED",
                        status="FAILED",
                        note="API did not return an MP3 URL for this surah.",
                    )
                )
                continue
            size = download_mp3(url, dest)
            rows.append(
                Row(
                    path=path,
                    title=title,
                    surah=f"Surah {surah:03d}",
                    reader=reciter.name,
                    source=reciter.source,
                    url=url,
                    license_info="UNVERIFIED (public recitation API; no separate license file found)",
                    status="DOWNLOADED",
                    size=human_size(size),
                )
            )
            log(f"  OK {human_size(size)} {url}")
        except Exception as exc:  # noqa: BLE001
            rows.append(
                Row(
                    path=path,
                    title=title,
                    surah=f"Surah {surah:03d}",
                    reader=reciter.name,
                    source=reciter.source,
                    status="FAILED",
                    note=str(exc),
                    license_info="UNVERIFIED",
                )
            )
            log(f"  FAIL {exc}")

    for path, title, surah, ayah in AYAH_DUAS:
        dest = ROOT / path
        ref = f"{surah}:{ayah}"
        log(f"Ayet {ref} → {path}")
        if skip_existing and dest.exists() and dest.stat().st_size > 0:
            row = existing_row(path, title, ref)
            rows.append(row)
            log(f"  skip existing ({row.size})")
            continue
        try:
            url = ayah_url(reciter, surah, ayah)
            if not url:
                row = existing_row(path, title, ref)
                if row.status == "ALREADY EXISTED":
                    row.note = (
                        "Ayah-level MP3 URL was not returned by this reciter API. "
                        "Existing file kept; no auto-crop from surah audio."
                    )
                    row.status = "MANUAL_REVIEW_REQUIRED"
                else:
                    row.status = "MANUAL_REQUIRED"
                    row.note = (
                        "Ayah-level MP3 not available from this reciter API. "
                        "Surah audio was not cropped."
                    )
                rows.append(row)
                log(f"  no ayah URL ({row.status})")
                continue
            size = download_mp3(url, dest)
            rows.append(
                Row(
                    path=path,
                    title=title,
                    surah=ref,
                    reader=reciter.name,
                    source=reciter.source,
                    url=url,
                    license_info="UNVERIFIED (public recitation API; no separate license file found)",
                    status="DOWNLOADED",
                    size=human_size(size),
                )
            )
            log(f"  OK {human_size(size)} {url}")
        except Exception as exc:  # noqa: BLE001
            row = existing_row(path, title, ref)
            row.status = "FAILED" if row.status == "MANUAL_REQUIRED" else "MANUAL_REVIEW_REQUIRED"
            row.note = str(exc)
            rows.append(row)
            log(f"  FAIL {exc}")

    for path, title in PRAYER_FILES:
        row = existing_row(path, title)
        if row.status == "ALREADY EXISTED":
            row.status = "MANUAL_REVIEW_REQUIRED"
            row.license_info = "UNVERIFIED"
            row.note = (
                "Pre-existing local file. License was not verified; file was not replaced."
            )
        else:
            row.status = "MANUAL_REQUIRED"
        rows.append(row)

    save_rows(rows, reciter)
    print_summary(rows)
    return 0 if not any(row.status == "FAILED" for row in rows) else 2


def print_summary(rows: list[Row]) -> None:
    counts = {
        "DOWNLOADED": 0,
        "ALREADY EXISTED": 0,
        "MANUAL_REQUIRED": 0,
        "MANUAL_REVIEW_REQUIRED": 0,
        "FAILED": 0,
    }
    created: list[str] = []
    total_bytes = 0
    for row in rows:
        counts[row.status] = counts.get(row.status, 0) + 1
        dest = ROOT / row.path
        if dest.exists():
            total_bytes += dest.stat().st_size
        if row.status == "DOWNLOADED":
            created.append(f"{row.path}  ({row.size})  {row.title}")

    print("\n========== SUMMARY ==========")
    print(f"TOTAL REQUESTED: {len(rows)}")
    print(f"DOWNLOADED: {counts['DOWNLOADED']}")
    print(f"ALREADY EXISTED: {counts['ALREADY EXISTED']}")
    print(f"MANUAL REQUIRED: {counts['MANUAL_REQUIRED']}")
    print(f"MANUAL REVIEW REQUIRED: {counts['MANUAL_REVIEW_REQUIRED']}")
    print(f"FAILED: {counts['FAILED']}")
    print(f"TOTAL AUDIO BYTES (listed files): {human_size(total_bytes)}")
    if created:
        print("\nDownloaded files:")
        for item in created:
            print(f"  {item}")
    print("Report: docs/audio_sources.md")


if __name__ == "__main__":
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        sys.exit(130)

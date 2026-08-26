#!/usr/bin/env python3
"""Generate educational Arabic MP3s for Minik Mümin Kur'an Öğren.

These are teacher-style pronunciation clips, not Quran recitation.
Kur'an-ı Kerim tilavet stays on real recitation assets under assets/audio/quran/.
Short surahs in namaz duaları / Kur'an Öğren use the same cartoon-boy TTS.
"""

from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
import logging
import subprocess
import sys
import time
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
AUDIO_ROOT = ROOT / "assets" / "audio" / "quran_learn"
LOG_PATH = ROOT / "logs" / "quran_learn_audio_generation.log"
MANIFEST_PATH = AUDIO_ROOT / "audio_manifest.json"
ARABIC_TTS_MANIFEST = ROOT / "assets" / "audio" / "arabic_tts_manifest.json"
DOCS_PATH = ROOT / "docs" / "quran_learn_audio_sources.md"
LANGUAGE = "ar-XA"
SPEAKING_RATE = 0.9
# Isolated letters need a slower clip so thick/thin (tafkhim/tarqiq) is audible.
PHONETIC_RATE = 0.86
# Prayer/dua clips: slower so madd, ghunnah and waqf stay audible.
PRAYER_RATE = 0.85
DUA_RATE = 0.82
SURAH_RATE = 0.82
# Fâtiha follows Alafasy murattal pace (reference only; playback is child TTS).
FATIHA_RATE = 0.5
FATIHA_GAP_MS = 1100
FATIHA_TARGET_SEC = 52.0
ASMA_RATE = 0.86
CHILD_PITCH = 8.0
# Chirp ignores API pitch; ffmpeg raises this many semitones for a cartoon-boy timbre.
CARTOON_SEMITONES = 5.0
PREFERRED_VOICES = (
    "ar-XA-Chirp3-HD-Fenrir",
    "ar-XA-Chirp3-HD-Sadachbia",
    "ar-XA-Chirp3-HD-Puck",
    "ar-XA-Chirp3-HD-Achird",
    "ar-XA-Chirp3-HD-Enceladus",
    "ar-XA-Neural2-B",
    "ar-XA-Neural2-C",
    "ar-XA-Wavenet-B",
    "ar-XA-Wavenet-C",
)
PAUSE_MARKS = ("ؕ", "ۚ", "ۖ", "ۗ", "ۘ", "ۙ", "ۛ", "ۜ", "ۢ", "۝", "\u08d5")
CHUNK_GAP_MS = 180
CARTOON_RATE = 48000
TAFKHIM_IDS = frozenset(
    {"kha", "sad", "dad", "ghayn", "ta_heavy", "za_heavy", "qaf"}
)
PHONETIC_CATEGORIES = frozenset(
    {
        "harakat_exercise",
        "letter_combination",
        "madd",
        "sukun_letter",
        "shadda_letter",
        "syllable",
        "combine",
    }
)

# Isolated ه would collide with ح if both used ha.mp3.
# ح → ha.mp3, ه → hah.mp3
LETTERS = [
    ("elif", "ا", "أَلِف"),
    ("ba", "ب", "بَاء"),
    ("ta", "ت", "تَاء"),
    ("tha", "ث", "ثَاء"),
    ("jim", "ج", "جِيم"),
    ("ha", "ح", "حَاء"),
    ("kha", "خ", "خَاء"),
    ("dal", "د", "دَال"),
    ("dhal", "ذ", "ذَال"),
    ("ra", "ر", "رَاء"),
    ("zay", "ز", "زَاي"),
    ("sin", "س", "سِين"),
    ("shin", "ش", "شِين"),
    ("sad", "ص", "صَاد"),
    ("dad", "ض", "ضَاد"),
    ("ta_heavy", "ط", "طَاء"),
    ("za_heavy", "ظ", "ظَاء"),
    ("ayn", "ع", "عَيْن"),
    ("ghayn", "غ", "غَيْن"),
    ("fa", "ف", "فَاء"),
    ("qaf", "ق", "قَاف"),
    ("kaf", "ك", "كَاف"),
    ("lam", "ل", "لَام"),
    ("mim", "م", "مِيم"),
    ("nun", "ن", "نُون"),
    ("hah", "ه", "هَاء"),
    ("waw", "و", "وَاو"),
    ("ya", "ي", "يَاء"),
]

HARAKA = [
    ("fatha", "َ", "فَتْحَة"),
    ("kasra", "ِ", "كَسْرَة"),
    ("damma", "ُ", "ضَمَّة"),
]
TANWIN = [
    ("fathatayn", "ً", "فَتْحَتَيْن"),
    ("kasratayn", "ٍ", "كَسْرَتَيْن"),
    ("dammatayn", "ٌ", "ضَمَّتَيْن"),
]
MADD_LETTERS = (
    "ba",
    "ta",
    "mim",
    "nun",
    "ra",
    "sin",
    "lam",
    "jim",
    "sad",
    "dad",
    "ta_heavy",
    "qaf",
    "kha",
)
COMBINATION_LETTERS = (
    "ba",
    "ta",
    "nun",
    "mim",
    "ra",
    "lam",
    "sin",
    "kaf",
    "fa",
    "ya",
    "sad",
    "dad",
    "ta_heavy",
    "za_heavy",
    "qaf",
    "kha",
    "ghayn",
)
SUKUN_IDS = (
    "ba",
    "ta",
    "mim",
    "nun",
    "sin",
    "lam",
    "ra",
    "kaf",
    "fa",
    "dal",
    "jim",
    "qaf",
    "ta_heavy",
    "sad",
)
SHADDA_IDS = (
    "ba",
    "ta",
    "mim",
    "nun",
    "lam",
    "ra",
    "sin",
    "dal",
    "sad",
    "ta_heavy",
    "qaf",
)
SYLLABLE_IDS = (
    "ba",
    "ta",
    "mim",
    "nun",
    "ra",
    "sin",
    "sad",
    "ta_heavy",
    "qaf",
    "kaf",
)
COMBINE_DRILLS = (
    ("ba_ta", "بَتَ"),
    ("ma_na", "مَنَ"),
    ("ta_ta_heavy", "تَطَ"),
    ("sin_sad", "سَصَ"),
    ("kaf_qaf", "كَقَ"),
)
LEARN_SURAH_NUMBERS = (1, 112, 113, 114, 108, 103, 109, 110, 111, 105, 106, 107)
PRAYER_AUDIO_PATHS = {
    "besmele": "assets/audio/prayer/besmele.mp3",
    "euzu_besmele": "assets/audio/prayer/euzu_besmele.mp3",
    "euzu": "assets/audio/prayer/euzu_besmele.mp3",
    "hamdele": "assets/audio/prayer/hamdele.mp3",
    "kelime_i_tevhid": "assets/audio/prayer/kelime_i_tevhid.mp3",
    "kelime_i_sehadet": "assets/audio/prayer/kelime_i_sehadet.mp3",
    "subhaneke": "assets/audio/prayer/subhaneke.mp3",
    "tahiyyat": "assets/audio/prayer/tahiyyat.mp3",
    "allahumme_salli": "assets/audio/prayer/allahumme_salli.mp3",
    "allahumme_barik": "assets/audio/prayer/allahumme_barik.mp3",
    "rabbena_atina": "assets/audio/duas/rabbena_atina.mp3",
    "rabbena_gfirli": "assets/audio/prayer/rabbena_gfirli.mp3",
    "ruku": "assets/audio/prayer/ruku_tesbihi.mp3",
    "qiyam_after_ruku": "assets/audio/prayer/rukudan_dogrulurken.mp3",
    "sujud": "assets/audio/prayer/sujud_tesbihi.mp3",
    "iftitah_tekbir": "assets/audio/prayer/iftitah_tekbir.mp3",
    "rabbena_lekel_hamd": "assets/audio/prayer/rabbena_lekel_hamd.mp3",
}

# Human recitations now live at these paths. --replace-old must not
# overwrite them with TTS.
PROTECTED_PRAYER_AUDIO = frozenset(
    path
    for key, path in PRAYER_AUDIO_PATHS.items()
    if path.startswith("assets/audio/prayer/")
)

# Quran-ayah dua recitations. --replace-old must not overwrite them with TTS.
PROTECTED_DUA_AUDIO = frozenset(
    {
        "assets/audio/duas/rabbena_atina.mp3",
        "assets/audio/duas/quran_002_201.mp3",
        "assets/audio/duas/quran_002_286.mp3",
        "assets/audio/duas/quran_003_008.mp3",
        "assets/audio/duas/quran_003_016.mp3",
        "assets/audio/duas/quran_003_053.mp3",
        "assets/audio/duas/quran_007_023.mp3",
        "assets/audio/duas/quran_007_126.mp3",
        "assets/audio/duas/quran_014_040.mp3",
        "assets/audio/duas/quran_014_041.mp3",
        "assets/audio/duas/quran_018_010.mp3",
        "assets/audio/duas/quran_020_025.mp3",
        "assets/audio/duas/quran_020_114.mp3",
        "assets/audio/duas/quran_021_083.mp3",
        "assets/audio/duas/quran_021_087.mp3",
        "assets/audio/duas/quran_023_097.mp3",
        "assets/audio/duas/quran_023_118.mp3",
        "assets/audio/duas/quran_025_074.mp3",
        "assets/audio/duas/quran_028_024.mp3",
        "assets/audio/duas/quran_059_010.mp3",
        "assets/audio/duas/quran_066_008.mp3",
    }
)

# Namaz / Kur'an Öğren short-surah tilavet (Alafasy copies of assets/audio/quran/).
PROTECTED_LEARN_SURAH_AUDIO = frozenset(
    f"assets/audio/quran_learn/surahs/surah_{number:03d}.mp3"
    for number in LEARN_SURAH_NUMBERS
)

PROTECTED_WUDU_AUDIO = frozenset({"assets/audio/wudu/abdest_duasi.mp3"})

PROTECTED_DHIKR_AUDIO = frozenset(
    {
        "assets/audio/dhikr/bismillah.mp3",
        "assets/audio/dhikr/subhanallah.mp3",
        "assets/audio/dhikr/alhamdulillah.mp3",
        "assets/audio/dhikr/allahu_akbar.mp3",
    }
)


def is_protected_audio(rel_path: str) -> bool:
    return rel_path in (
        PROTECTED_PRAYER_AUDIO
        | PROTECTED_DUA_AUDIO
        | PROTECTED_LEARN_SURAH_AUDIO
        | PROTECTED_WUDU_AUDIO
        | PROTECTED_DHIKR_AUDIO
    )


@dataclass(frozen=True)
class Clip:
    clip_id: str
    category: str
    arabic: str
    rel_path: str
    extra: str | None = None
    phonetic: bool = False
    repeat: int = 2
    speaking_rate: float | None = None
    gap_ms: int | None = None
    target_seconds: float | None = None


# Spoken dua starts must already exist inside duas.json arabic.
# Audio speaks only the invocation, not the narrative frame of the ayah.
DUA_SPOKEN_STARTS: dict[str, str] = {
    "quran_dua_2_201": "رَبَّنَٓا اٰتِنَا",
    "quran_dua_2_286": "رَبَّنَا لَا تُؤَاخِذْنَٓا",
    "quran_dua_3_16": "رَبَّنَٓا اِنَّنَٓا",
    "quran_dua_7_23": "رَبَّنَا ظَلَمْنَٓا",
    "quran_dua_7_126": "رَبَّنَٓا اَفْرِغْ",
    "quran_dua_18_10": "رَبَّنَٓا اٰتِنَا مِنْ لَدُنْكَ",
    "quran_dua_20_25": "رَبِّ اشْرَحْ",
    "quran_dua_20_114": "رَبِّ زِدْنٖی",
    "quran_dua_21_83": "اَنّٖی مَسَّنِیَ",
    "quran_dua_21_87": "لَٓا اِلٰهَ اِلَّٓا اَنْتَ",
    "quran_dua_23_97": "رَبِّ اَعُوذُ",
    "quran_dua_23_118": "رَبِّ اغْفِرْ",
    "quran_dua_25_74": "رَبَّنَا هَبْ",
    "quran_dua_28_24": "رَبِّ اِنّٖی لِمَٓا",
    "quran_dua_59_10": "رَبَّنَا اغْفِرْ لَنَا وَلِاِخْوَانِنَا",
    "quran_dua_66_8": "رَبَّنَٓا اَتْمِمْ",
}

NARRATIVE_PREFIXES = (
    "قَالَا ",
    "قَالَ ",
    "فَقَالُوا ",
    "فَقَالَ ",
    "وَقُلْ ",
    "فَقُلْ ",
)


def log_line(kind: str, message: str) -> None:
    logging.info("[%s] %s", kind, message)
    print(f"[{kind}] {message}", flush=True)


def configure_logging() -> None:
    LOG_PATH.parent.mkdir(parents=True, exist_ok=True)
    logging.basicConfig(
        filename=str(LOG_PATH),
        filemode="a",
        level=logging.INFO,
        format="%(asctime)s %(message)s",
    )


def adc_token_from_gcloud() -> str | None:
    try:
        proc = subprocess.run(
            ["gcloud", "auth", "application-default", "print-access-token"],
            check=False,
            capture_output=True,
            text=True,
            timeout=20,
        )
    except FileNotFoundError:
        return None
    if proc.returncode != 0:
        return None
    token = (proc.stdout or "").strip()
    return token or None


def require_adc() -> None:
    token = adc_token_from_gcloud()
    if token:
        return
    try:
        from google.auth import default as google_auth_default
        from google.auth.exceptions import DefaultCredentialsError

        google_auth_default(scopes=["https://www.googleapis.com/auth/cloud-platform"])
    except Exception as exc:  # noqa: BLE001
        raise RuntimeError(
            "Google Cloud Application Default Credentials bulunamadı.\n"
            "Kur'an Öğren eğitim seslerini üretmek için ADC gerekir.\n\n"
            "Yapman gereken:\n"
            "  1) Google Cloud SDK kur: https://cloud.google.com/sdk/docs/install\n"
            "  2) gcloud auth application-default login\n"
            "  3) Text-to-Speech API açık bir proje seç\n"
            "  4) python3 scripts/setup_quran_learn_audio.py\n"
            "  5) python3 scripts/generate_quran_learn_audio.py --test\n\n"
            "Service account JSON, API key veya credential dosyasını "
            "assets/ veya Dart koduna koyma.\n"
            f"Detay: {exc}"
        ) from exc


def letter_by_id(letter_id: str) -> tuple[str, str, str]:
    for item in LETTERS:
        if item[0] == letter_id:
            return item
    raise KeyError(letter_id)


def with_haraka(letter: str, mark: str, letter_id: str) -> str:
    if letter_id == "elif":
        if mark == "َ":
            return "أَ"
        if mark == "ِ":
            return "إِ"
        if mark == "ُ":
            return "أُ"
        if mark == "ً":
            return "أً"
        if mark == "ٍ":
            return "إٍ"
        if mark == "ٌ":
            return "أٌ"
    return letter + mark


def xml_escape(text: str) -> str:
    return (
        text.replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace('"', "&quot;")
        .replace("'", "&apos;")
    )


def phonetic_ssml(arabic: str, extra: str | None = None, *, repeat: int = 2) -> str:
    """Teacher-style: repeat the sounded glyph, then optionally the letter name."""
    sounded = xml_escape(arabic.strip())
    chunks = [sounded] * max(1, repeat)
    body = '<break time="320ms"/>'.join(chunks)
    if extra:
        body += f'<break time="480ms"/>{xml_escape(extra.strip())}'
    return f"<speak>{body}</speak>"


def phonetic_fallback_text(arabic: str, extra: str | None = None, *, repeat: int = 2) -> str:
    parts = [arabic.strip()] * max(1, repeat)
    if extra:
        parts.append(extra.strip())
    return "، ".join(part for part in parts if part)


def extract_spoken_arabic(arabic: str, item_id: str = "") -> str:
    """Keep JSON Arabic unchanged on screen; speak only the dua already in it."""
    text = " ".join(arabic.strip().split())
    if not text:
        return text
    start = DUA_SPOKEN_STARTS.get(item_id)
    if start:
        idx = text.find(start)
        if idx >= 0:
            spoken = text[idx:].strip()
            if spoken and spoken in text:
                return spoken
    for prefix in NARRATIVE_PREFIXES:
        if text.startswith(prefix):
            return text[len(prefix) :].strip()
    return text


def build_catalog(*, test: bool) -> list[Clip]:
    clips: list[Clip] = []

    def add(
        clip_id: str,
        category: str,
        arabic: str,
        rel: str,
        *,
        extra: str | None = None,
        phonetic: bool | None = None,
        repeat: int | None = None,
    ) -> None:
        is_phonetic = category in PHONETIC_CATEGORIES if phonetic is None else phonetic
        clips.append(
            Clip(
                clip_id=clip_id,
                category=category,
                arabic=arabic,
                rel_path=f"assets/audio/quran_learn/{rel}",
                extra=extra,
                phonetic=is_phonetic,
                repeat=2 if repeat is None else repeat,
            )
        )

    if test:
        add("ba", "alphabet", "بَاء", "alphabet/ba.mp3", phonetic=False, repeat=1)
        add("ta_heavy", "alphabet", "طَاء", "alphabet/ta_heavy.mp3", phonetic=False, repeat=1)
        add("ba_fatha", "harakat_exercise", "بَ", "exercises/ba_fatha.mp3")
        add("ta_heavy_fatha", "harakat_exercise", "طَ", "exercises/ta_heavy_fatha.mp3")
        add("ba_sukun", "sukun_letter", "بْ", "sukun/ba_sukun.mp3")
        add("ba_shadda", "shadda_letter", "بَّ", "shadda/ba_shadda.mp3")
        return clips

    for letter_id, glyph, name in LETTERS:
        spoken_name = "مِيمْ" if letter_id == "mim" else name
        add(
            letter_id,
            "alphabet",
            spoken_name,
            f"alphabet/{letter_id}.mp3",
            phonetic=False,
            repeat=1,
        )

    for haraka_id, _mark, name in HARAKA:
        add(haraka_id, "harakat", name, f"harakat/{haraka_id}.mp3")

    for letter_id, glyph, _name in LETTERS:
        for haraka_id, mark, _hname in HARAKA:
            arabic = with_haraka(glyph, mark, letter_id)
            add(
                f"{letter_id}_{haraka_id}",
                "harakat_exercise",
                arabic,
                f"exercises/{letter_id}_{haraka_id}.mp3",
                repeat=3 if letter_id in TAFKHIM_IDS and haraka_id == "fatha" else 2,
            )

    for tanwin_id, _mark, name in TANWIN:
        add(tanwin_id, "tanwin", name, f"tanwin/{tanwin_id}.mp3")
    for letter_id, glyph, _name in LETTERS:
        if letter_id == "elif":
            continue
        for tanwin_id, mark, _tname in TANWIN:
            add(
                f"{letter_id}_{tanwin_id}",
                "tanwin_letter",
                glyph + mark,
                f"tanwin/{letter_id}_{tanwin_id}.mp3",
            )

    add("sukun", "sukun", "سُكُون", "sukun/sukun.mp3")
    add("eb", "sukun_letter", "أَبْ", "sukun/eb.mp3")
    for letter_id in SUKUN_IDS:
        glyph = letter_by_id(letter_id)[1]
        add(
            f"{letter_id}_sukun",
            "sukun_letter",
            glyph + "ْ",
            f"sukun/{letter_id}_sukun.mp3",
        )

    add("shadda", "shadda", "شَدَّة", "shadda/shadda.mp3")
    for letter_id in SHADDA_IDS:
        glyph = letter_by_id(letter_id)[1]
        add(
            f"{letter_id}_shadda",
            "shadda_letter",
            glyph + "َّ",
            f"shadda/{letter_id}_shadda.mp3",
        )

    for letter_id in MADD_LETTERS:
        glyph = letter_by_id(letter_id)[1]
        add(
            f"{letter_id}_madd_alif",
            "madd",
            glyph + "َا",
            f"madd/{letter_id}_madd_alif.mp3",
        )
        add(
            f"{letter_id}_madd_ya",
            "madd",
            glyph + "ِي",
            f"madd/{letter_id}_madd_ya.mp3",
        )
        add(
            f"{letter_id}_madd_waw",
            "madd",
            glyph + "ُو",
            f"madd/{letter_id}_madd_waw.mp3",
        )

    for letter_id in COMBINATION_LETTERS:
        glyph = letter_by_id(letter_id)[1]
        add(
            f"{letter_id}_alif_join",
            "letter_combination",
            glyph + "ا",
            f"letter_combinations/{letter_id}_alif.mp3",
        )

    for clip_id, arabic in COMBINE_DRILLS:
        add(clip_id, "combine", arabic, f"combine/{clip_id}.mp3")

    for letter_id in SYLLABLE_IDS:
        glyph = letter_by_id(letter_id)[1]
        add(f"{letter_id}_fatha_syl", "syllable", glyph + "َ", f"syllables/{letter_id}_fatha.mp3")
        add(f"{letter_id}_kasra_syl", "syllable", glyph + "ِ", f"syllables/{letter_id}_kasra.mp3")
        add(f"{letter_id}_damma_syl", "syllable", glyph + "ُ", f"syllables/{letter_id}_damma.mp3")

    words = [
        ("allah", "الله"),
        ("rabb", "رَبّ"),
        ("muhammad", "مُحَمَّد"),
        ("kitab", "كِتَاب"),
        ("noor", "نُور"),
        ("rahman", "رَحْمَٰن"),
        ("jannah", "جَنَّة"),
        ("nas", "نَاس"),
        ("qul", "قُل"),
        ("ahad", "أَحَد"),
        ("word_01", "الله"),
        ("word_02", "بِسْمِ"),
        ("word_03", "الْحَمْدُ"),
        ("word_04", "رَبِّ"),
        ("word_05", "الْعَالَمِينَ"),
        ("word_06", "الرَّحْمَٰنِ"),
        ("word_07", "الرَّحِيمِ"),
        ("word_08", "مَالِكِ"),
        ("word_09", "يَوْمِ"),
        ("word_10", "الدِّينِ"),
        ("word_11", "إِيَّاكَ"),
        ("word_12", "نَعْبُدُ"),
        ("word_13", "وَإِيَّاكَ"),
        ("word_14", "نَسْتَعِينُ"),
        ("word_15", "اهْدِنَا"),
        ("word_16", "الصِّرَاطَ"),
        ("word_17", "الْمُسْتَقِيمَ"),
        ("word_18", "قُلْ"),
        ("word_19", "هُوَ"),
        ("word_20", "أَحَدٌ"),
        ("word_21", "الصَّمَدُ"),
        ("word_22", "لَمْ"),
        ("word_23", "يَلِدْ"),
        ("word_24", "يُولَدْ"),
    ]
    for word_id, arabic in words:
        add(word_id, "word", arabic, f"words/{word_id}.mp3")
    add("izhar", "tajweed", "أَنْعَمْتَ", "tajweed/izhar.mp3", phonetic=False, repeat=2)
    clips.extend(build_surah_clips())
    return clips


def load_kuran_ayet() -> list[dict]:
    path = ROOT / "assets" / "data" / "kuran.json"
    payload = json.loads(path.read_text(encoding="utf-8"))
    ayet = payload.get("ayet")
    if not isinstance(ayet, list):
        raise RuntimeError("kuran.json içinde ayet listesi yok.")
    return ayet


def surah_arabic_from_kuran(
    surah_number: int,
    ayet: list[dict],
    *,
    separate_ayahs: bool = False,
) -> str:
    verses = [
        item
        for item in ayet
        if int(item.get("sure_id") or 0) == surah_number
    ]
    verses.sort(key=lambda item: int(item.get("ayet_no") or 0))
    parts = []
    for item in verses:
        metin = item.get("metin") if isinstance(item.get("metin"), dict) else {}
        arabic = str(metin.get("arapca") or "").strip()
        if arabic:
            parts.append(arabic)
    return "\n".join(parts) if separate_ayahs else " ".join(parts)


def build_surah_clips() -> list[Clip]:
    ayet = load_kuran_ayet()
    clips: list[Clip] = []
    for number in LEARN_SURAH_NUMBERS:
        arabic = surah_arabic_from_kuran(
            number,
            ayet,
            separate_ayahs=number == 1,
        )
        if not arabic:
            log_line("FAILED", f"sure {number} için kuran.json Arapçası boş")
            continue
        padded = f"{number:03d}"
        clips.append(
            Clip(
                clip_id=f"surah_{padded}",
                category="surah",
                arabic=arabic,
                rel_path=f"assets/audio/quran_learn/surahs/surah_{padded}.mp3",
                speaking_rate=FATIHA_RATE if number == 1 else SURAH_RATE,
                gap_ms=FATIHA_GAP_MS if number == 1 else None,
                target_seconds=FATIHA_TARGET_SEC if number == 1 else None,
            )
        )
    return clips


def build_replace_clips() -> list[Clip]:
    clips: list[Clip] = []
    namaz = json.loads((ROOT / "assets" / "data" / "namaz_dualari.json").read_text(encoding="utf-8"))
    for item in namaz.get("items") or []:
        item_id = str(item.get("id") or "").strip()
        if not item_id or item.get("type") == "surah":
            continue
        arabic = extract_spoken_arabic(str(item.get("arabic") or "").strip(), item_id)
        dest = PRAYER_AUDIO_PATHS.get(item_id, f"assets/audio/prayer/{item_id}.mp3")
        if is_protected_audio(dest):
            continue
        if not arabic:
            stale = ROOT / dest
            if stale.exists():
                stale.unlink()
                log_line("REMOVED", dest)
            continue
        clips.append(
            Clip(
                clip_id=f"prayer_{item_id}",
                category="prayer",
                arabic=arabic,
                rel_path=dest,
                speaking_rate=PRAYER_RATE,
            )
        )
    duas = json.loads((ROOT / "assets" / "data" / "duas.json").read_text(encoding="utf-8"))
    for item in duas.get("items") or []:
        source_arabic = str(item.get("arabic") or "").strip()
        dest = str(item.get("audio") or "").strip()
        item_id = str(item.get("id") or "").strip()
        if is_protected_audio(dest):
            continue
        arabic = extract_spoken_arabic(source_arabic, item_id)
        if not arabic or not dest:
            continue
        if arabic != source_arabic:
            log_line("EXTRACT", f"{item_id}: dua-only Arabic from JSON ayah")
        clips.append(
            Clip(
                clip_id=f"dua_{item_id}",
                category="dua",
                arabic=arabic,
                rel_path=dest,
                speaking_rate=DUA_RATE,
            )
        )
    asma_path = ROOT / "assets" / "data" / "asmaul_husna.json"
    if asma_path.exists():
        asma = json.loads(asma_path.read_text(encoding="utf-8"))
        for item in asma.get("items") or []:
            arabic = str(item.get("arabic") or "").strip()
            dest = str(item.get("audio") or "").strip()
            item_id = str(item.get("id") or "").strip()
            if not arabic or not dest:
                continue
            spoken = apply_waqf_to_phrase(normalize_mushaf_for_tts(arabic))
            if spoken != arabic:
                log_line("WAQF", f"asma_{item_id}: stop without final haraka")
            clips.append(
                Clip(
                    clip_id=f"asma_{item_id}",
                    category="asma",
                    arabic=spoken,
                    rel_path=dest,
                    speaking_rate=ASMA_RATE,
                )
            )
    wudu_path = ROOT / "assets" / "data" / "wudu.json"
    if wudu_path.exists():
        wudu = json.loads(wudu_path.read_text(encoding="utf-8"))
        dua = wudu.get("completionDua") or {}
        arabic = str(dua.get("arabic") or "").strip()
        dest = str(dua.get("audio") or "").strip()
        if arabic and dest and not is_protected_audio(dest):
            clips.append(
                Clip(
                    clip_id="wudu_abdest_duasi",
                    category="dua",
                    arabic=arabic,
                    rel_path=dest,
                    speaking_rate=DUA_RATE,
                )
            )
    return clips


def list_arabic_voices(client, *, gender: str | None) -> list:
    from google.cloud import texttospeech

    voices = []
    for voice in client.list_voices(language_code=LANGUAGE).voices:
        voice_gender = texttospeech.SsmlVoiceGender(voice.ssml_gender).name
        if gender and voice_gender != gender:
            continue
        if LANGUAGE not in list(voice.language_codes):
            continue
        voices.append(voice)
    return voices


def choose_voice(client) -> str:
    male = list_arabic_voices(client, gender="MALE")
    names = {voice.name for voice in male}
    if not names:
        names = {voice.name for voice in list_arabic_voices(client, gender=None)}
    if not names:
        raise RuntimeError("API'de ar-XA ses bulunamadı.")
    for preferred in PREFERRED_VOICES:
        if preferred in names:
            return preferred
    chirp = sorted(name for name in names if "Chirp3-HD" in name)
    if chirp:
        return chirp[0]
    neural = sorted(name for name in names if "Neural2" in name)
    if neural:
        return neural[0]
    wavenet = sorted(name for name in names if "Wavenet" in name)
    if wavenet:
        return wavenet[0]
    return sorted(names)[0]


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(65536), b""):
            digest.update(chunk)
    return digest.hexdigest()


def looks_like_mp3(path: Path) -> bool:
    if not path.exists() or path.stat().st_size <= 0:
        return False
    header = path.read_bytes()[:3]
    return header == b"ID3" or header[:2] in (b"\xff\xfb", b"\xff\xf3", b"\xff\xf2", b"\xff\xfa")


_SHORT_VOWELS = frozenset("ًٌٍَُِْ")
_SUKUN = "ْ"
_MADD_STOP = frozenset("اأإآىو")


def _is_arabic_letter(ch: str) -> bool:
    code = ord(ch)
    if 0x0621 <= code <= 0x063A:
        return True
    if 0x0641 <= code <= 0x064A:
        return True
    return code in {0x0629, 0x0649, 0x06CC, 0x0671, 0x0672, 0x0673, 0x0675}


def _letter_clusters(word: str) -> list[list[str]]:
    clusters: list[list[str]] = []
    for char in word:
        if _is_arabic_letter(char):
            clusters.append([char, ""])
        elif clusters:
            clusters[-1][1] += char
    return clusters


def waqf_last_word(word: str) -> str:
    """Stop on the last letter: drop final haraka/tanwin, read as sukun."""
    clusters = _letter_clusters(word)
    if not clusters:
        return word
    last_letter, last_marks = clusters[-1]
    prev_marks = clusters[-2][1] if len(clusters) > 1 else ""
    tanwin_fatha = "ً" in last_marks or "ً" in prev_marks
    if last_letter in "اأى" and tanwin_fatha:
        clusters.pop()
        if not clusters:
            return word
        last_letter, last_marks = clusters[-1]
    kept = "".join(mark for mark in last_marks if mark not in _SHORT_VOWELS)
    if last_letter == "ة":
        last_letter = "ه"
    elif last_letter == "ئ":
        last_letter = "ء"
    if last_letter in _MADD_STOP:
        clusters[-1] = [last_letter, kept]
    else:
        clusters[-1] = [last_letter, kept + _SUKUN]
    return "".join(letter + marks for letter, marks in clusters)


def normalize_mushaf_for_tts(arabic: str) -> str:
    """Keep JSON on screen; only normalize mushaf marks Chirp misreads as other words."""
    text = arabic.strip()
    text = text.replace("ی", "ي")
    # Subscript alef is a kasra-length mark, not an extra ي letter.
    text = text.replace("ٖ", "ِ")
    text = text.replace("اٰ", "آ")
    text = text.replace("ٰى", "ى")
    text = text.replace("ىٰ", "ى")
    text = text.replace("ٰ", "ا")
    # Maddah stretches ا; converting ٓا to آ would add a hamza in الضالين.
    text = text.replace("ٓ", "")
    for mark in ("،", "؛"):
        text = text.replace(mark, " ")
    return " ".join(text.split())


def apply_waqf_to_phrase(phrase: str) -> str:
    words = phrase.split()
    if not words:
        return phrase
    words[-1] = waqf_last_word(words[-1])
    return " ".join(words)


# Extra madd letters Chirp should hold. Counts follow tilavet, not display JSON.
# tabii ~2 harakat, muttasil/munfasil/arid ~4, lazim ~6.
_MADD_EXTRA = {
    "tabii": 1,
    "badal": 1,
    "muttasil": 2,
    "munfasil": 2,
    "arid": 2,
    "lazim": 4,
}
_HAMZA_QAT = frozenset("أإؤئءآ")


def _has_mark(marks: str, chars: str) -> bool:
    return any(char in marks for char in chars)


def _is_madd_carrier(letter: str, marks: str) -> bool:
    if letter in "اآى":
        return not _has_mark(marks, "ُِ")
    if letter == "و":
        return not _has_mark(marks, "ًٌٍَُِ")
    if letter == "ي":
        return not _has_mark(marks, "ًٌٍَُِ")
    return False


def _madd_kind_for_previous(letter: str, prev_marks: str) -> str | None:
    if letter in "اآى":
        if _has_mark(prev_marks, "ً"):
            return None
        if _has_mark(prev_marks, "َ"):
            return "alif"
        # Dagger alif (ٰ → ا) often leaves the previous letter without َ.
        if not _has_mark(prev_marks, "ًٌٍَُِْ"):
            return "alif"
        return None
    if letter == "و" and _has_mark(prev_marks, "ُ") and not _has_mark(prev_marks, "ٌ"):
        return "waw"
    if letter == "ي" and _has_mark(prev_marks, "ِ") and not _has_mark(prev_marks, "ٍ"):
        return "yeh"
    return None


def _stretch_glyph(letter: str) -> str:
    """Hold alif-class madd with extra ا so Chirp lengthens ā, not a new hamza/yeh."""
    if letter in "آاى":
        return "ا"
    return letter


def _is_stretch_copy(origin: str, letter: str, marks: str) -> bool:
    if _has_mark(marks, "ًٌٍَُِ"):
        return False
    if letter == origin:
        return True
    return origin in "آاى" and letter == "ا"


def _following_index(clusters: list[list[str]], madd_idx: int) -> int | None:
    origin = clusters[madd_idx][0]
    index = madd_idx + 1
    while index < len(clusters) and _is_stretch_copy(
        origin, clusters[index][0], clusters[index][1]
    ):
        index += 1
    if index >= len(clusters):
        return None
    return index


def _stretch_madd(clusters: list[list[str]], madd_idx: int, extra: int) -> None:
    origin = clusters[madd_idx][0]
    glyph = _stretch_glyph(origin)
    end = madd_idx + 1
    while end < len(clusters) and _is_stretch_copy(
        origin, clusters[end][0], clusters[end][1]
    ):
        end += 1
    del clusters[madd_idx + 1 : end]
    for _ in range(extra):
        clusters.insert(madd_idx + 1, [glyph, ""])


def _starts_with_hamza_qat(word: str) -> bool:
    clusters = _letter_clusters(word.lstrip())
    if not clusters:
        return False
    letter, marks = clusters[0]
    if letter in _HAMZA_QAT:
        return True
    return letter == "ا" and _has_mark(marks, "ًٌٍَُِ")


def _classify_madd(
    clusters: list[list[str]],
    madd_idx: int,
    *,
    next_word: str,
    is_last_word: bool,
) -> str:
    follow_idx = _following_index(clusters, madd_idx)
    if follow_idx is not None:
        follow_letter, follow_marks = clusters[follow_idx]
        if _has_mark(follow_marks, "ّ"):
            return "lazim"
        if follow_letter in _HAMZA_QAT:
            return "muttasil"
        if (
            is_last_word
            and _has_mark(follow_marks, "ْ")
            and follow_idx == len(clusters) - 1
        ):
            return "arid"
        if madd_idx == 0 and clusters[madd_idx][0] in "اآ":
            return "badal"
        return "tabii"
    if _starts_with_hamza_qat(next_word):
        return "munfasil"
    return "tabii"


def apply_tajweed_madd(phrase: str) -> str:
    """Lengthen madd letters in TTS input only; JSON on screen stays unchanged."""
    words = phrase.split()
    stretched: list[str] = []
    for index, word in enumerate(words):
        clusters = _letter_clusters(word)
        if not clusters:
            stretched.append(word)
            continue
        next_word = words[index + 1] if index + 1 < len(words) else ""
        is_last_word = index == len(words) - 1
        madd_indexes: list[int] = []
        first_letter, first_marks = clusters[0]
        if first_letter == "آ" and _is_madd_carrier(first_letter, first_marks):
            madd_indexes.append(0)
        for pos in range(1, len(clusters)):
            letter, marks = clusters[pos]
            if not _is_madd_carrier(letter, marks):
                continue
            if _madd_kind_for_previous(letter, clusters[pos - 1][1]):
                madd_indexes.append(pos)
        for pos in reversed(madd_indexes):
            kind = _classify_madd(
                clusters,
                pos,
                next_word=next_word,
                is_last_word=is_last_word,
            )
            _stretch_madd(clusters, pos, _MADD_EXTRA[kind])
        stretched.append("".join(letter + marks for letter, marks in clusters))
    return " ".join(stretched)


def tts_input_text(arabic: str) -> str:
    """Normalize mushaf glyphs, apply waqf at stops, then stretch tajweed madd."""
    raw = arabic.replace("\r", "\n")
    for mark in PAUSE_MARKS:
        raw = raw.replace(mark, "\n")
    phrases: list[str] = []
    for piece in raw.split("\n"):
        normalized = normalize_mushaf_for_tts(piece)
        if not normalized:
            continue
        stopped = apply_waqf_to_phrase(normalized)
        phrases.append(apply_tajweed_madd(stopped))
    return " ".join(phrases)


def spoken_chunks(arabic: str) -> list[str]:
    """Prefer one pass. Newline-separated ayahs keep murattal pauses."""
    collapsed = tts_input_text(arabic)
    keep_phrases = "\n" in arabic.replace("\r", "\n")
    if keep_phrases:
        chunks: list[str] = []
        for piece in arabic.replace("\r", "\n").split("\n"):
            cleaned = tts_input_text(piece)
            if cleaned:
                chunks.append(cleaned)
        return chunks or [collapsed]
    if len(collapsed) <= 420:
        return [collapsed] if collapsed else [tts_input_text(arabic)]
    raw = arabic.replace("\r", "\n")
    for mark in PAUSE_MARKS:
        raw = raw.replace(mark, "\n")
    chunks = []
    for piece in raw.split("\n"):
        cleaned = tts_input_text(piece)
        if cleaned:
            chunks.append(cleaned)
    return chunks or [collapsed]


def synthesize(
    client,
    voice_name: str,
    dest: Path,
    *,
    text: str,
    ssml: str | None = None,
    speaking_rate: float = SPEAKING_RATE,
    allow_pitch: bool,
    process_text: bool = True,
) -> None:
    from google.cloud import texttospeech

    dest.parent.mkdir(parents=True, exist_ok=True)
    voice = texttospeech.VoiceSelectionParams(language_code=LANGUAGE, name=voice_name)
    use_pitch = allow_pitch and "Chirp" not in voice_name
    audio_config_kwargs = {
        "audio_encoding": texttospeech.AudioEncoding.MP3,
        "speaking_rate": speaking_rate,
    }
    if use_pitch:
        audio_config_kwargs["pitch"] = CHILD_PITCH
    audio_config = texttospeech.AudioConfig(**audio_config_kwargs)

    spoken = tts_input_text(text) if process_text else text
    attempts: list[texttospeech.SynthesisInput] = []
    if ssml:
        attempts.append(texttospeech.SynthesisInput(ssml=ssml))
    attempts.append(texttospeech.SynthesisInput(text=spoken))

    last_error: Exception | None = None
    for input_index, synthesis_input in enumerate(attempts):
        for attempt in range(1, 4):
            try:
                kind = "ssml" if synthesis_input.ssml else "text"
                log_line(
                    "RETRY" if attempt > 1 or input_index else "START",
                    f"{dest} {kind} attempt={attempt}",
                )
                response = client.synthesize_speech(
                    input=synthesis_input,
                    voice=voice,
                    audio_config=audio_config,
                )
                audio = response.audio_content or b""
                if not audio:
                    raise RuntimeError("API empty audio_content")
                part = dest.with_suffix(dest.suffix + ".part")
                part.write_bytes(audio)
                if part.stat().st_size <= 0:
                    part.unlink(missing_ok=True)
                    raise RuntimeError("0-byte MP3")
                part.replace(dest)
                return
            except Exception as exc:  # noqa: BLE001
                last_error = exc
                message = str(exc)
                if allow_pitch and "pitch" in message.lower():
                    log_line("RETRY", "pitch not supported; retrying without pitch")
                    synthesize(
                        client,
                        voice_name,
                        dest,
                        text=text,
                        ssml=ssml if input_index == 0 else None,
                        speaking_rate=speaking_rate,
                        allow_pitch=False,
                        process_text=process_text,
                    )
                    return
                if ssml and input_index == 0 and (
                    attempt == 3 or "ssml" in message.lower() or "invalid" in message.lower()
                ):
                    log_line("RETRY", f"{dest} SSML failed; falling back to text")
                    break
                wait = 2 ** (attempt - 1)
                log_line("RETRY", f"{dest} failed: {exc}; sleep {wait}s")
                time.sleep(wait)
    raise RuntimeError(f"TTS failed for {dest}: {last_error}") from last_error


def decode_mp3_pcm(path: Path, rate: int = CARTOON_RATE) -> tuple[bytes, int, int]:
    import wave

    wav = path.with_suffix(path.suffix + f".{rate}.wav")
    conv = subprocess.run(
        ["afconvert", "-f", "WAVE", "-d", f"LEI16@{rate}", str(path), str(wav)],
        check=False,
        capture_output=True,
        text=True,
        timeout=60,
    )
    if conv.returncode != 0 or not wav.exists():
        wav.unlink(missing_ok=True)
        raise RuntimeError(conv.stderr.strip() or "afconvert decode failed")
    try:
        with wave.open(str(wav), "rb") as reader:
            channels = reader.getnchannels()
            width = reader.getsampwidth()
            pcm = reader.readframes(reader.getnframes())
    finally:
        wav.unlink(missing_ok=True)
    if width != 2 or channels < 1 or not pcm:
        raise RuntimeError("unsupported wav")
    return pcm, channels, rate


def trim_pcm(pcm: bytes, channels: int, rate: int, *, thresh: int = 380, pad_ms: int = 70) -> bytes:
    frame = 2 * channels
    total = len(pcm) // frame
    if total == 0:
        return pcm

    def amp(i: int) -> int:
        peak = 0
        off = i * frame
        for ch in range(channels):
            s = int.from_bytes(pcm[off + ch * 2 : off + ch * 2 + 2], "little", signed=True)
            peak = max(peak, abs(s))
        return peak

    peak = 0
    for i in range(total):
        peak = max(peak, amp(i))
    cut = max(thresh, int(peak * 0.06) if peak else thresh)

    start = 0
    while start < total and amp(start) < cut:
        start += 1
    end = total - 1
    while end > start and amp(end) < cut:
        end -= 1
    pad = int(rate * pad_ms / 1000)
    start = max(0, start - pad)
    end = min(total - 1, end + pad)
    return pcm[start * frame : (end + 1) * frame]


def pitch_pcm(pcm: bytes, channels: int, ratio: float) -> bytes:
    frame = 2 * channels
    src_frames = len(pcm) // frame
    dst_frames = max(1, int(src_frames / ratio))
    out = bytearray(dst_frames * frame)
    for i in range(dst_frames):
        src = i * ratio
        a = int(src)
        b = min(a + 1, src_frames - 1)
        frac = src - a
        a_off = a * frame
        b_off = b * frame
        for ch in range(channels):
            sa = int.from_bytes(pcm[a_off + ch * 2 : a_off + ch * 2 + 2], "little", signed=True)
            sb = int.from_bytes(pcm[b_off + ch * 2 : b_off + ch * 2 + 2], "little", signed=True)
            val = int(sa * (1 - frac) + sb * frac)
            val = max(-32768, min(32767, val))
            o = i * frame + ch * 2
            out[o : o + 2] = val.to_bytes(2, "little", signed=True)
    return bytes(out)


def encode_mp3(pcm: bytes, dest: Path, channels: int, rate: int) -> None:
    import lameenc

    encoder = lameenc.Encoder()
    encoder.set_bit_rate(128)
    encoder.set_in_sample_rate(rate)
    encoder.set_channels(channels)
    encoder.set_quality(2)
    mp3_data = encoder.encode(pcm) + encoder.flush()
    if not mp3_data:
        raise RuntimeError("empty mp3 encode")
    dest.write_bytes(mp3_data)


def match_mp3_duration(path: Path, target_sec: float, *, max_slow: float = 2.0) -> None:
    pcm, channels, rate = decode_mp3_pcm(path)
    current = len(pcm) / (2 * channels * rate)
    if current <= 0 or target_sec <= current * 1.08:
        return
    slow = min(max_slow, target_sec / current)
    pcm = pitch_pcm(pcm, channels, 1 / slow)
    encode_mp3(pcm, path, channels, rate)
    log_line("TEMPO", f"{path.name} {current:.1f}s -> {current * slow:.1f}s (Alafasy pace)")


def join_pcm(parts: list[bytes], channels: int, rate: int, gap_ms: int) -> bytes:
    gap = bytes(int(rate * gap_ms / 1000) * 2 * channels)
    return gap.join(parts)


def cartoonize_mp3(path: Path) -> None:
    """Raise pitch after TTS so the clip sounds like a cartoon-boy character."""
    if CARTOON_SEMITONES == 0:
        return
    try:
        pcm, channels, rate = decode_mp3_pcm(path)
        pcm = trim_pcm(pcm, channels, rate)
        pcm = pitch_pcm(pcm, channels, 2 ** (CARTOON_SEMITONES / 12))
        encode_mp3(pcm, path, channels, rate)
    except Exception as exc:  # noqa: BLE001
        log_line("RETRY", f"cartoon pitch skipped for {path}: {exc}")


def render_spoken_mp3(
    client,
    voice_name: str,
    dest: Path,
    *,
    arabic: str,
    speaking_rate: float,
    gap_ms: int | None = None,
    target_seconds: float | None = None,
) -> None:
    chunks = spoken_chunks(arabic)
    pause = CHUNK_GAP_MS if gap_ms is None else gap_ms
    log_line("START", f"{dest} chunks={len(chunks)} gap_ms={pause}")
    if len(chunks) == 1:
        synthesize(
            client,
            voice_name,
            dest,
            text=chunks[0],
            speaking_rate=speaking_rate,
            allow_pitch=True,
            process_text=False,
        )
    else:
        decoded: list[tuple[bytes, int, int]] = []
        temps: list[Path] = []
        try:
            for index, chunk in enumerate(chunks):
                tmp = dest.with_suffix(f".chunk{index}.mp3")
                temps.append(tmp)
                synthesize(
                    client,
                    voice_name,
                    tmp,
                    text=chunk,
                    speaking_rate=speaking_rate,
                    allow_pitch=True,
                    process_text=False,
                )
                pcm, channels, rate = decode_mp3_pcm(tmp)
                decoded.append((trim_pcm(pcm, channels, rate, pad_ms=50), channels, rate))
            channels = decoded[0][1]
            rate = decoded[0][2]
            pcm = join_pcm([item[0] for item in decoded], channels, rate, pause)
            pcm = trim_pcm(pcm, channels, rate)
            encode_mp3(pcm, dest, channels, rate)
        finally:
            for tmp in temps:
                tmp.unlink(missing_ok=True)
    if target_seconds:
        pre_cartoon = target_seconds * (2 ** (CARTOON_SEMITONES / 12))
        match_mp3_duration(dest, pre_cartoon)
    cartoonize_mp3(dest)


def write_manifest(entries: list[dict], voice: str) -> None:
    AUDIO_ROOT.mkdir(parents=True, exist_ok=True)
    payload = {
        "module": "quran_learn",
        "kind": "educational_tts",
        "not_quran_recitation": True,
        "voice": voice,
        "language": LANGUAGE,
        "rate": SPEAKING_RATE,
        "pitch": CHILD_PITCH,
        "cartoon_semitones": CARTOON_SEMITONES,
        "generated_at": dt.datetime.now(dt.timezone.utc).isoformat(),
        "items": entries,
    }
    MANIFEST_PATH.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")


def write_sources_doc(voice: str, generated: int, skipped: int, failed: int) -> None:
    DOCS_PATH.parent.mkdir(parents=True, exist_ok=True)
    DOCS_PATH.write_text(
        "\n".join(
            [
                "# Kur'an Öğren educational audio sources",
                "",
                "These files were generated using Google Cloud Text-to-Speech. "
                "The audio files are synthetic outputs generated from the supplied text. "
                "Review Google Cloud's current terms and pricing before commercial redistribution.",
                "",
                "This audio is **educational pronunciation**, not Quran recitation, adhan, "
                "or qari imitation. Short surahs here use the same cartoon-boy TTS. "
                "Fâtiha pacing follows Alafasy murattal as a reference, but the clip is child TTS. "
                "Kur'an-ı Kerim tilavet stays on Husary (`assets/audio/quran/`).",
                "",
                f"- Voice: `{voice}`",
                f"- Language: `{LANGUAGE}`",
                f"- Speaking rate: `{SPEAKING_RATE}` (isolated letters `{PHONETIC_RATE}`)",
                f"- Pitch: `{CHILD_PITCH}` (Neural2/Wavenet only; Chirp omits API pitch)",
                f"- Cartoon pitch shift: `{CARTOON_SEMITONES}` semitones after TTS (cartoon-boy timbre)",
                "- Voice style: cartoon-boy educational speaker, not a deep adult qari.",
                "- Isolated letter cards speak the letter name only (e.g. بَاء).",
                "- Haraka chips (üstün/esre/ötre) still use sounded syllables (e.g. طَ).",
                "- API: Google Cloud Text-to-Speech (`google-cloud-texttospeech`)",
                "- Auth: Application Default Credentials (no keys in the Flutter app)",
                f"- Generated date: {dt.date.today().isoformat()}",
                f"- Generated: {generated}",
                f"- Skipped: {skipped}",
                f"- Failed: {failed}",
                "",
                "Documentation:",
                "- https://cloud.google.com/text-to-speech/docs",
                "- https://cloud.google.com/terms",
                "",
                "License is **not** marked royalty-free or public domain.",
                "",
                "Letter `ه` is stored as `alphabet/hah.mp3` because `ha.mp3` is used for `ح`.",
                "",
            ]
        ),
        encoding="utf-8",
    )


def make_client():
    from google.cloud import texttospeech

    return texttospeech.TextToSpeechClient()


def run(
    test: bool,
    force: bool,
    clips: list[Clip] | None = None,
    write_docs: bool = True,
    write_arabic_manifest: bool = False,
) -> int:
    configure_logging()
    log_line("START", "Kur'an Öğren educational TTS")
    require_adc()
    client = make_client()
    voice = choose_voice(client)
    log_line("START", f"VOICE={voice} LANGUAGE={LANGUAGE} RATE={SPEAKING_RATE}")

    clips = clips if clips is not None else build_catalog(test=test)
    generated = skipped = failed = 0
    entries: list[dict] = []
    manifest_path = ARABIC_TTS_MANIFEST if write_arabic_manifest else MANIFEST_PATH
    if manifest_path.exists():
        try:
            previous = json.loads(manifest_path.read_text(encoding="utf-8"))
            entries = list(previous.get("items") or [])
        except json.JSONDecodeError:
            entries = []
    by_id = {item.get("id"): item for item in entries}

    for clip in clips:
        dest = ROOT / clip.rel_path
        dest.parent.mkdir(parents=True, exist_ok=True)
        if is_protected_audio(clip.rel_path) and looks_like_mp3(dest):
            skipped += 1
            log_line("PROTECTED", clip.rel_path)
            if clip.clip_id not in by_id:
                by_id[clip.clip_id] = {
                    "id": clip.clip_id,
                    "category": clip.category,
                    "arabic": clip.arabic,
                    "path": clip.rel_path,
                    "format": "mp3",
                    "sha256": sha256_file(dest),
                    "kind": "human_recitation",
                    "not_educational_tts": True,
                }
            continue
        if not force and looks_like_mp3(dest):
            skipped += 1
            log_line("SKIPPED", clip.rel_path)
            by_id[clip.clip_id] = {
                "id": clip.clip_id,
                "category": clip.category,
                "arabic": clip.arabic,
                "path": clip.rel_path,
                "voice": voice,
                "language": LANGUAGE,
                "rate": clip.speaking_rate or SPEAKING_RATE,
                "format": "mp3",
                "sha256": sha256_file(dest),
                "generated_at": dt.datetime.fromtimestamp(
                    dest.stat().st_mtime, tz=dt.timezone.utc
                ).isoformat(),
            }
            continue
        try:
            rate = clip.speaking_rate or SPEAKING_RATE
            if clip.phonetic:
                rate = PHONETIC_RATE
                synthesize(
                    client,
                    voice,
                    dest,
                    text=phonetic_fallback_text(
                        clip.arabic, clip.extra, repeat=clip.repeat
                    ),
                    ssml=phonetic_ssml(clip.arabic, clip.extra, repeat=clip.repeat),
                    speaking_rate=rate,
                    allow_pitch=True,
                )
                cartoonize_mp3(dest)
            else:
                render_spoken_mp3(
                    client,
                    voice,
                    dest,
                    arabic=clip.arabic,
                    speaking_rate=rate,
                    gap_ms=clip.gap_ms,
                    target_seconds=clip.target_seconds,
                )
            if not looks_like_mp3(dest):
                dest.unlink(missing_ok=True)
                raise RuntimeError("output was not a valid MP3")
            generated += 1
            log_line("GENERATED", f"{clip.rel_path} ({dest.stat().st_size} bytes)")
            by_id[clip.clip_id] = {
                "id": clip.clip_id,
                "category": clip.category,
                "arabic": clip.arabic,
                "path": clip.rel_path,
                "voice": voice,
                "language": LANGUAGE,
                "rate": rate,
                "format": "mp3",
                "sha256": sha256_file(dest),
                "generated_at": dt.datetime.now(dt.timezone.utc).isoformat(),
            }
        except Exception as exc:  # noqa: BLE001
            failed += 1
            log_line("FAILED", f"{clip.rel_path}: {exc}")

    seen: set[str] = set()
    ordered: list[dict] = []
    for clip in clips:
        item = by_id.get(clip.clip_id)
        if item:
            ordered.append(item)
            seen.add(clip.clip_id)
    for item in entries:
        cid = str(item.get("id") or "")
        if cid and cid not in seen:
            ordered.append(item)
            seen.add(cid)
    if write_arabic_manifest:
        ARABIC_TTS_MANIFEST.parent.mkdir(parents=True, exist_ok=True)
        ARABIC_TTS_MANIFEST.write_text(
            json.dumps(
                {
                    "module": "prayer_duas_asma",
                    "kind": "educational_tts",
                    "not_quran_recitation": True,
                    "arabic_only": True,
                    "voice": voice,
                    "language": LANGUAGE,
                    "cartoon_semitones": CARTOON_SEMITONES,
                    "generated_at": dt.datetime.now(dt.timezone.utc).isoformat(),
                    "items": ordered,
                },
                ensure_ascii=False,
                indent=2,
            ),
            encoding="utf-8",
        )
    else:
        write_manifest(ordered, voice)
        if write_docs:
            write_sources_doc(voice, generated, skipped, failed)

    missing = [clip.rel_path for clip in clips if not looks_like_mp3(ROOT / clip.rel_path)]
    total_bytes = sum((ROOT / clip.rel_path).stat().st_size for clip in clips if (ROOT / clip.rel_path).exists())
    print("\n========== SUMMARY ==========")
    print(f"TOTAL AUDIO ASSETS: {len(clips)}")
    print(f"GENERATED: {generated}")
    print(f"SKIPPED: {skipped}")
    print(f"FAILED: {failed}")
    print(f"MISSING: {len(missing)}")
    print(f"VOICE:\n{voice}")
    print(f"LANGUAGE:\n{LANGUAGE}")
    print(f"RATE:\n{SPEAKING_RATE}")
    print(f"TOTAL BYTES: {total_bytes}")
    if missing:
        print("Missing files:")
        for path in missing:
            print(f"  {path}")
    return 0 if failed == 0 and not missing else 2


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--test", action="store_true", help="Generate only the 6 sample clips.")
    parser.add_argument("--all", action="store_true", help="Generate the full educational set.")
    parser.add_argument(
        "--replace-old",
        action="store_true",
        help="Overwrite namaz/dua/asma clips with Fenrir cartoon-boy Arabic TTS.",
    )
    parser.add_argument(
        "--asma",
        action="store_true",
        help="Overwrite Esmaül Hüsna clips; stop on the last letter (no final haraka).",
    )
    parser.add_argument("--force", action="store_true", help="Regenerate files that already exist.")
    parser.add_argument(
        "--phonetics",
        action="store_true",
        help="Regenerate isolated letter/haraka clips with thick vs thin sounds.",
    )
    parser.add_argument(
        "--letters",
        action="store_true",
        help="Regenerate alphabet clips as letter names only (no sounded syllable).",
    )
    parser.add_argument(
        "--surahs",
        action="store_true",
        help="Overwrite short-surah clips with Fenrir cartoon-boy educational TTS.",
    )
    parser.add_argument(
        "--fatiha",
        action="store_true",
        help="Regenerate Fâtiha child TTS using Alafasy murattal pace as reference.",
    )
    parser.add_argument("--check-auth", action="store_true", help="Only verify ADC and list voices.")
    args = parser.parse_args()
    try:
        if args.check_auth:
            require_adc()
            client = make_client()
            voice = choose_voice(client)
            print(f"ADC OK\nVOICE={voice}\nLANGUAGE={LANGUAGE}")
            return 0
        if args.replace_old:
            return run(
                test=False,
                force=True,
                clips=build_replace_clips(),
                write_docs=False,
                write_arabic_manifest=True,
            )
        if args.asma:
            clips = [clip for clip in build_replace_clips() if clip.category == "asma"]
            return run(
                test=False,
                force=True,
                clips=clips,
                write_docs=False,
                write_arabic_manifest=True,
            )
        if args.letters:
            clips = [clip for clip in build_catalog(test=False) if clip.category == "alphabet"]
            return run(test=False, force=True, clips=clips, write_docs=False)
        if args.surahs:
            return run(
                test=False,
                force=True,
                clips=build_surah_clips(),
                write_docs=False,
            )
        if args.fatiha:
            clips = [clip for clip in build_surah_clips() if clip.clip_id == "surah_001"]
            return run(
                test=False,
                force=True,
                clips=clips,
                write_docs=False,
                write_arabic_manifest=True,
            )
        if args.phonetics:
            clips = [clip for clip in build_catalog(test=False) if clip.phonetic]
            return run(test=False, force=True, clips=clips)
        if not args.test and not args.all:
            print(
                "Use --test, --all, --letters, --phonetics, --surahs, --fatiha, --asma or --replace-old",
                file=sys.stderr,
            )
            return 64
        return run(test=args.test, force=args.force)
    except RuntimeError as exc:
        print(str(exc), file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())

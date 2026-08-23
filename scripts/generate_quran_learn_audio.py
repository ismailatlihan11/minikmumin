#!/usr/bin/env python3
"""Generate educational Arabic MP3s for Minik Mümin Kur'an Öğren.

These are teacher-style pronunciation clips, not Quran recitation.
Surah tilawat is handled separately by real recitation assets.
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
DOCS_PATH = ROOT / "docs" / "quran_learn_audio_sources.md"
LANGUAGE = "ar-XA"
SPEAKING_RATE = 0.9
# Isolated letters need a slower clip so thick/thin (tafkhim/tarqiq) is audible.
PHONETIC_RATE = 0.86
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
# Huruf al-isti'la: these must not be synthesized as letter names only.
TAFKHIM_IDS = frozenset(
    {"kha", "sad", "dad", "ghayn", "ta_heavy", "za_heavy", "qaf"}
)
PHONETIC_CATEGORIES = frozenset(
    {
        "alphabet",
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
}


@dataclass(frozen=True)
class Clip:
    clip_id: str
    category: str
    arabic: str
    rel_path: str
    extra: str | None = None
    phonetic: bool = False
    repeat: int = 2


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
        add("ba", "alphabet", "بَ", "alphabet/ba.mp3", extra="بَاء")
        add("ta_heavy", "alphabet", "طَ", "alphabet/ta_heavy.mp3", extra="طَاء")
        add("ba_fatha", "harakat_exercise", "بَ", "exercises/ba_fatha.mp3")
        add("ta_heavy_fatha", "harakat_exercise", "طَ", "exercises/ta_heavy_fatha.mp3")
        add("ba_sukun", "sukun_letter", "بْ", "sukun/ba_sukun.mp3")
        add("ba_shadda", "shadda_letter", "بَّ", "shadda/ba_shadda.mp3")
        return clips

    for letter_id, glyph, name in LETTERS:
        sounded = with_haraka(glyph, "َ", letter_id)
        add(
            letter_id,
            "alphabet",
            sounded,
            f"alphabet/{letter_id}.mp3",
            extra=name,
            repeat=3 if letter_id in TAFKHIM_IDS else 2,
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


def surah_arabic_from_kuran(surah_number: int, ayet: list[dict]) -> str:
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
    return " ".join(parts)


def build_surah_clips() -> list[Clip]:
    ayet = load_kuran_ayet()
    clips: list[Clip] = []
    for number in LEARN_SURAH_NUMBERS:
        arabic = surah_arabic_from_kuran(number, ayet)
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
            )
        )
    return clips


def build_replace_clips() -> list[Clip]:
    clips = build_surah_clips()
    namaz = json.loads((ROOT / "assets" / "data" / "namaz_dualari.json").read_text(encoding="utf-8"))
    for item in namaz.get("items") or []:
        item_id = str(item.get("id") or "").strip()
        if not item_id or item.get("type") == "surah":
            continue
        arabic = str(item.get("arabic") or "").strip()
        dest = PRAYER_AUDIO_PATHS.get(item_id, f"assets/audio/prayer/{item_id}.mp3")
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
            )
        )
    duas = json.loads((ROOT / "assets" / "data" / "duas.json").read_text(encoding="utf-8"))
    for item in duas.get("items") or []:
        arabic = str(item.get("arabic") or "").strip()
        dest = str(item.get("audio") or "").strip()
        item_id = str(item.get("id") or "").strip()
        if not arabic or not dest:
            continue
        clips.append(
            Clip(
                clip_id=f"dua_{item_id}",
                category="dua",
                arabic=arabic,
                rel_path=dest,
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


def tts_input_text(arabic: str) -> str:
    """Chirp rejects very long sentences; keep JSON Arabic unchanged."""
    text = arabic.strip()
    for mark in ("ؕ", "ۚ", "ۖ", "ۗ", "ۘ", "ۙ", "ۛ", "ۜ", "ۢ", "۝", "،", "؛"):
        text = text.replace(mark, ". ")
    return " ".join(text.split())


def synthesize(
    client,
    voice_name: str,
    dest: Path,
    *,
    text: str,
    ssml: str | None = None,
    speaking_rate: float = SPEAKING_RATE,
    allow_pitch: bool,
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

    attempts: list[texttospeech.SynthesisInput] = []
    if ssml:
        attempts.append(texttospeech.SynthesisInput(ssml=ssml))
    attempts.append(texttospeech.SynthesisInput(text=tts_input_text(text)))

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


def cartoonize_mp3(path: Path) -> None:
    """Raise pitch after TTS so the clip sounds like a cartoon-boy character.

    Chirp voices ignore API pitch. macOS afconvert decodes MP3; samples are
    shortened (classic cartoon/chipmunk) then re-encoded with lameenc.
    """
    if CARTOON_SEMITONES == 0:
        return
    ratio = 2 ** (CARTOON_SEMITONES / 12)
    wav = path.with_suffix(".cartoon.wav")
    tmp_mp3 = path.with_suffix(".cartoon.mp3")
    try:
        conv = subprocess.run(
            ["afconvert", "-f", "WAVE", "-d", "LEI16@24000", str(path), str(wav)],
            check=False,
            capture_output=True,
            text=True,
            timeout=30,
        )
        if conv.returncode != 0 or not wav.exists():
            log_line("RETRY", f"cartoon decode skipped for {path}: {conv.stderr.strip()}")
            return
        import wave

        with wave.open(str(wav), "rb") as reader:
            channels = reader.getnchannels()
            sample_width = reader.getsampwidth()
            rate = reader.getframerate()
            nframes = reader.getnframes()
            pcm = reader.readframes(nframes)
        if sample_width != 2 or channels < 1 or not pcm:
            log_line("RETRY", f"cartoon wav unsupported for {path}")
            return
        frame_width = sample_width * channels
        src_frames = len(pcm) // frame_width
        dst_frames = max(1, int(src_frames / ratio))
        out = bytearray(dst_frames * frame_width)
        for i in range(dst_frames):
            src = i * ratio
            a = int(src)
            b = min(a + 1, src_frames - 1)
            frac = src - a
            a_off = a * frame_width
            b_off = b * frame_width
            for ch in range(channels):
                a_idx = a_off + ch * 2
                b_idx = b_off + ch * 2
                sa = int.from_bytes(pcm[a_idx : a_idx + 2], "little", signed=True)
                sb = int.from_bytes(pcm[b_idx : b_idx + 2], "little", signed=True)
                val = int(sa * (1 - frac) + sb * frac)
                val = max(-32768, min(32767, val))
                o = i * frame_width + ch * 2
                out[o : o + 2] = val.to_bytes(2, "little", signed=True)
        with wave.open(str(wav), "wb") as writer:
            writer.setnchannels(channels)
            writer.setsampwidth(2)
            writer.setframerate(rate)
            writer.writeframes(bytes(out))
        import lameenc

        encoder = lameenc.Encoder()
        encoder.set_bit_rate(64)
        encoder.set_in_sample_rate(rate)
        encoder.set_channels(channels)
        encoder.set_quality(5)
        mp3_data = encoder.encode(bytes(out)) + encoder.flush()
        if not mp3_data:
            log_line("RETRY", f"cartoon encode empty for {path}")
            return
        tmp_mp3.write_bytes(mp3_data)
        tmp_mp3.replace(path)
    except Exception as exc:  # noqa: BLE001
        log_line("RETRY", f"cartoon pitch skipped for {path}: {exc}")
    finally:
        wav.unlink(missing_ok=True)
        tmp_mp3.unlink(missing_ok=True)


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
                "or qari imitation. Short-surah tilawat stays on real recitation assets.",
                "",
                f"- Voice: `{voice}`",
                f"- Language: `{LANGUAGE}`",
                f"- Speaking rate: `{SPEAKING_RATE}` (isolated letters `{PHONETIC_RATE}`)",
                f"- Pitch: `{CHILD_PITCH}` (Neural2/Wavenet only; Chirp omits API pitch)",
                f"- Cartoon pitch shift: `{CARTOON_SEMITONES}` semitones after TTS (cartoon-boy timbre)",
                "- Voice style: cartoon-boy educational speaker, not a deep adult qari.",
                "- Isolated letters are generated as sounded syllables (e.g. طَ), "
                "not only letter names, so thick/thin Arabic sounds stay distinct.",
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


def run(test: bool, force: bool, clips: list[Clip] | None = None, write_docs: bool = True) -> int:
    configure_logging()
    log_line("START", "Kur'an Öğren educational TTS")
    require_adc()
    client = make_client()
    voice = choose_voice(client)
    log_line("START", f"VOICE={voice} LANGUAGE={LANGUAGE} RATE={SPEAKING_RATE}")

    clips = clips if clips is not None else build_catalog(test=test)
    generated = skipped = failed = 0
    entries: list[dict] = []
    if MANIFEST_PATH.exists():
        try:
            previous = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
            entries = list(previous.get("items") or [])
        except json.JSONDecodeError:
            entries = []
    by_id = {item.get("id"): item for item in entries}

    for clip in clips:
        dest = ROOT / clip.rel_path
        dest.parent.mkdir(parents=True, exist_ok=True)
        if clip.category == "surah":
            skipped += 1
            log_line("SKIPPED", f"{clip.rel_path} (tilavet; educational TTS overwritten değil)")
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
                "rate": SPEAKING_RATE,
                "format": "mp3",
                "sha256": sha256_file(dest),
                "generated_at": dt.datetime.fromtimestamp(
                    dest.stat().st_mtime, tz=dt.timezone.utc
                ).isoformat(),
            }
            continue
        try:
            ssml = None
            spoken = tts_input_text(clip.arabic)
            rate = SPEAKING_RATE
            if clip.phonetic:
                rate = PHONETIC_RATE
                ssml = phonetic_ssml(clip.arabic, clip.extra, repeat=clip.repeat)
                spoken = phonetic_fallback_text(
                    clip.arabic, clip.extra, repeat=clip.repeat
                )
            synthesize(
                client,
                voice,
                dest,
                text=spoken,
                ssml=ssml,
                speaking_rate=rate,
                allow_pitch=True,
            )
            cartoonize_mp3(dest)
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
                "rate": SPEAKING_RATE,
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
        help="Overwrite namaz/dua clips and generate short-surah educational TTS.",
    )
    parser.add_argument("--force", action="store_true", help="Regenerate files that already exist.")
    parser.add_argument(
        "--phonetics",
        action="store_true",
        help="Regenerate isolated letter/haraka clips with thick vs thin sounds.",
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
            return run(test=False, force=True, clips=build_replace_clips(), write_docs=False)
        if args.phonetics:
            clips = [clip for clip in build_catalog(test=False) if clip.phonetic]
            return run(test=False, force=True, clips=clips)
        if not args.test and not args.all:
            print("Use --test, --all, --phonetics or --replace-old", file=sys.stderr)
            return 64
        return run(test=args.test, force=args.force)
    except RuntimeError as exc:
        print(str(exc), file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())

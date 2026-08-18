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
SPEAKING_RATE = 0.85
PREFERRED_VOICES = (
    "ar-XA-Chirp3-HD-Achird",
    "ar-XA-Chirp3-HD-Algenib",
    "ar-XA-Chirp3-HD-Algieba",
    "ar-XA-Chirp3-HD-Alnilam",
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
MADD_LETTERS = ("ba", "ta", "mim", "nun", "ra", "sin", "lam", "jim")
COMBINATION_LETTERS = ("ba", "ta", "nun", "mim", "ra", "lam", "sin", "kaf", "fa", "ya")
SUKUN_IDS = ("ba", "ta", "mim", "nun", "sin", "lam", "ra", "kaf", "fa", "dal")
SHADDA_IDS = ("ba", "ta", "mim", "nun", "lam", "ra", "sin", "dal")
SYLLABLE_IDS = ("ba", "ta", "mim", "nun", "ra", "sin")


@dataclass(frozen=True)
class Clip:
    clip_id: str
    category: str
    arabic: str
    rel_path: str


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


def build_catalog(*, test: bool) -> list[Clip]:
    clips: list[Clip] = []

    def add(clip_id: str, category: str, arabic: str, rel: str) -> None:
        clips.append(
            Clip(
                clip_id=clip_id,
                category=category,
                arabic=arabic,
                rel_path=f"assets/audio/quran_learn/{rel}",
            )
        )

    if test:
        add("ba", "alphabet", "بَاء", "alphabet/ba.mp3")
        add("ba_fatha", "harakat_exercise", "بَ", "exercises/ba_fatha.mp3")
        add("ba_kasra", "harakat_exercise", "بِ", "exercises/ba_kasra.mp3")
        add("ba_damma", "harakat_exercise", "بُ", "exercises/ba_damma.mp3")
        add("ba_sukun", "sukun", "بْ", "sukun/ba_sukun.mp3")
        add("ba_shadda", "shadda", "بَّ", "shadda/ba_shadda.mp3")
        return clips

    for letter_id, glyph, name in LETTERS:
        add(letter_id, "alphabet", name, f"alphabet/{letter_id}.mp3")

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
            )

    for tanwin_id, _mark, name in TANWIN:
        add(tanwin_id, "tanwin", name, f"tanwin/{tanwin_id}.mp3")
    for letter_id, glyph, _name in LETTERS:
        if letter_id == "elif":
            continue
        for tanwin_id, mark, _tname in TANWIN:
            add(
                f"{letter_id}_{tanwin_id}",
                "tanwin",
                glyph + mark,
                f"tanwin/{letter_id}_{tanwin_id}.mp3",
            )

    add("sukun", "sukun", "سُكُون", "sukun/sukun.mp3")
    for letter_id in SUKUN_IDS:
        glyph = letter_by_id(letter_id)[1]
        add(f"{letter_id}_sukun", "sukun", glyph + "ْ", f"sukun/{letter_id}_sukun.mp3")

    add("shadda", "shadda", "شَدَّة", "shadda/shadda.mp3")
    for letter_id in SHADDA_IDS:
        glyph = letter_by_id(letter_id)[1]
        add(f"{letter_id}_shadda", "shadda", glyph + "َّ", f"shadda/{letter_id}_shadda.mp3")

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
    return clips


def list_arabic_male_voices(client) -> list:
    from google.cloud import texttospeech

    voices = []
    for voice in client.list_voices(language_code=LANGUAGE).voices:
        gender = texttospeech.SsmlVoiceGender(voice.ssml_gender).name
        if gender != "MALE":
            continue
        if LANGUAGE not in list(voice.language_codes):
            continue
        voices.append(voice)
    return voices


def choose_voice(client) -> str:
    voices = list_arabic_male_voices(client)
    names = {voice.name for voice in voices}
    if not names:
        raise RuntimeError("API'de ar-XA erkek ses bulunamadı.")
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


def synthesize(client, voice_name: str, text: str, dest: Path, allow_pitch: bool) -> None:
    from google.cloud import texttospeech

    dest.parent.mkdir(parents=True, exist_ok=True)
    synthesis_input = texttospeech.SynthesisInput(text=text)
    voice = texttospeech.VoiceSelectionParams(language_code=LANGUAGE, name=voice_name)
    audio_config_kwargs = {
        "audio_encoding": texttospeech.AudioEncoding.MP3,
        "speaking_rate": SPEAKING_RATE,
    }
    if allow_pitch:
        audio_config_kwargs["pitch"] = -1.5
    audio_config = texttospeech.AudioConfig(**audio_config_kwargs)

    last_error: Exception | None = None
    for attempt in range(1, 4):
        try:
            log_line("RETRY" if attempt > 1 else "START", f"{dest} attempt={attempt}")
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
                synthesize(client, voice_name, text, dest, allow_pitch=False)
                return
            wait = 2 ** (attempt - 1)
            log_line("RETRY", f"{dest} failed: {exc}; sleep {wait}s")
            time.sleep(wait)
    raise RuntimeError(f"TTS failed for {dest}: {last_error}") from last_error


def write_manifest(entries: list[dict], voice: str) -> None:
    AUDIO_ROOT.mkdir(parents=True, exist_ok=True)
    payload = {
        "module": "quran_learn",
        "kind": "educational_tts",
        "not_quran_recitation": True,
        "voice": voice,
        "language": LANGUAGE,
        "rate": SPEAKING_RATE,
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
                f"- Speaking rate: `{SPEAKING_RATE}`",
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


def run(test: bool, force: bool) -> int:
    configure_logging()
    log_line("START", "Kur'an Öğren educational TTS")
    require_adc()
    client = make_client()
    voice = choose_voice(client)
    log_line("START", f"VOICE={voice} LANGUAGE={LANGUAGE} RATE={SPEAKING_RATE}")

    clips = build_catalog(test=test)
    generated = skipped = failed = 0
    entries: list[dict] = []
    if MANIFEST_PATH.exists() and not force:
        try:
            previous = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
            entries = list(previous.get("items") or [])
        except json.JSONDecodeError:
            entries = []
    by_id = {item.get("id"): item for item in entries}

    for clip in clips:
        dest = ROOT / clip.rel_path
        dest.parent.mkdir(parents=True, exist_ok=True)
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
            synthesize(client, voice, clip.arabic, dest, allow_pitch=True)
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

    ordered = [by_id[clip.clip_id] for clip in clips if clip.clip_id in by_id]
    write_manifest(ordered, voice)
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
    parser.add_argument("--force", action="store_true", help="Regenerate files that already exist.")
    parser.add_argument("--check-auth", action="store_true", help="Only verify ADC and list voices.")
    args = parser.parse_args()
    try:
        if args.check_auth:
            require_adc()
            client = make_client()
            voice = choose_voice(client)
            print(f"ADC OK\nVOICE={voice}\nLANGUAGE={LANGUAGE}")
            return 0
        if not args.test and not args.all:
            print("Use --test or --all", file=sys.stderr)
            return 64
        return run(test=args.test, force=args.force)
    except RuntimeError as exc:
        print(str(exc), file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())

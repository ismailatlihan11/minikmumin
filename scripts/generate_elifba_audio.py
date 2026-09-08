"""Elifbâ modülünde eksik olan kayıtları üretir.

Plan `tool/audit_elifba_audio.dart --plan` tarafından çıkarılır: hangi dosya
eksik, ne söylemeli ve hangi dil gerekiyor. Heceler (be, si, su, eb, bbe)
Türkçe sesle, kelimeler ve hareke adları Arapça sesle okunur.

    dart run tool/audit_elifba_audio.dart --plan > /tmp/audio_plan.json
    python3 scripts/generate_elifba_audio.py /tmp/audio_plan.json
"""

import json
import subprocess
import sys
from pathlib import Path

VOICES = {
    "tr": ("tr-TR", "tr-TR-Wavenet-E"),
    "ar": ("ar-XA", "ar-XA-Chirp3-HD-Fenrir"),
}
SPEAKING_RATE = 0.85
MIN_BYTES = 2000
MIN_SECONDS = 0.4


def duration(path: Path) -> float:
    out = subprocess.run(["afinfo", str(path)], capture_output=True, text=True).stdout
    for line in out.splitlines():
        if "estimated duration" in line:
            return float(line.split(":")[1].strip().split(" ")[0])
    return 0.0


def spoken_text(item: dict) -> str:
    say = item["say"]
    # Tek hece yalnız bırakılınca motor harf adı gibi okuyabiliyor.
    return say if item["voice"] == "ar" else f"{say}, {say}"


def main(argv: list[str]) -> int:
    from google.cloud import texttospeech

    plan = json.loads(Path(argv[0]).read_text(encoding="utf-8"))
    client = texttospeech.TextToSpeechClient()
    config = texttospeech.AudioConfig(
        audio_encoding=texttospeech.AudioEncoding.MP3,
        speaking_rate=SPEAKING_RATE,
    )

    written, failed = 0, []
    for item in plan:
        dest = Path(item["path"])
        if dest.exists():
            continue
        language, voice_name = VOICES[item["voice"]]
        dest.parent.mkdir(parents=True, exist_ok=True)
        try:
            response = client.synthesize_speech(
                input=texttospeech.SynthesisInput(text=spoken_text(item)),
                voice=texttospeech.VoiceSelectionParams(
                    language_code=language, name=voice_name
                ),
                audio_config=config,
            )
        except Exception as exc:  # noqa: BLE001
            failed.append(f"{dest.name}: {exc}")
            continue
        audio = response.audio_content or b""
        if len(audio) < MIN_BYTES:
            failed.append(f"{dest.name}: {len(audio)} bayt")
            continue
        part = dest.with_suffix(".part")
        part.write_bytes(audio)
        seconds = duration(part)
        if seconds < MIN_SECONDS:
            failed.append(f"{dest.name}: {seconds:.2f} sn")
            part.unlink(missing_ok=True)
            continue
        part.replace(dest)
        written += 1
        print(f"{item['kind']:18s} {dest.name:28s} {item['say']}")

    print(f"\nyazılan: {written} · başarısız: {len(failed)}")
    for line in failed:
        print("  ", line)
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

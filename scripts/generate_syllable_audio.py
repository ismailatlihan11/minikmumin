"""Harekeli hece kayıtlarını (28 harf × üstün/esre/ötre) Türkçe sesle üretir.

Eski kayıtlar Arapça sese tek harf gönderilerek üretilmişti; motor tek harfi
çoğu zaman harfin adı gibi okuduğu için ötre sesi kayboluyordu (صُ = "sa").
Burada metin, uygulamadaki okuma kuralından gelir: kartta "su" yazıyorsa
kayıt da "su" der.

Plan dosyası: `dart run tool/print_syllable_plan.dart > /tmp/syllable_plan.json`
Kullanım:     python3 scripts/generate_syllable_audio.py /tmp/syllable_plan.json
"""

import json
import subprocess
import sys
from pathlib import Path

DEST = Path("assets/audio/elifba/exercises")
LANGUAGE = "tr-TR"
VOICE = "tr-TR-Wavenet-E"
SPEAKING_RATE = 0.85
MIN_BYTES = 2000
MIN_SECONDS = 0.4


def duration(path: Path) -> float:
    out = subprocess.run(["afinfo", str(path)], capture_output=True, text=True).stdout
    for line in out.splitlines():
        if "estimated duration" in line:
            return float(line.split(":")[1].strip().split(" ")[0])
    return 0.0


def main(argv: list[str]) -> int:
    from google.cloud import texttospeech

    plan_path = Path(argv[0] if argv else "/tmp/syllable_plan.json")
    plan = json.loads(plan_path.read_text(encoding="utf-8"))
    client = texttospeech.TextToSpeechClient()
    voice = texttospeech.VoiceSelectionParams(language_code=LANGUAGE, name=VOICE)
    config = texttospeech.AudioConfig(
        audio_encoding=texttospeech.AudioEncoding.MP3,
        speaking_rate=SPEAKING_RATE,
    )

    written, failed = 0, []
    for stem, entry in plan.items():
        for haraka, reading in entry["readings"].items():
            dest = DEST / f"{stem}_{haraka}.mp3"
            # Tek hece yalnız bırakılınca motor harf adı gibi okuyabiliyor;
            # iki kez söyletmek hem sesi netleştiriyor hem tekrar imkânı veriyor.
            response = client.synthesize_speech(
                input=texttospeech.SynthesisInput(text=f"{reading}, {reading}"),
                voice=voice,
                audio_config=config,
            )
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
            print(f"{dest.name:20s} {reading:4s} {seconds:.2f} sn")

    print(f"\nyazılan: {written} · başarısız: {len(failed)}")
    for item in failed:
        print("  ", item)
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

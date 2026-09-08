"""Harekeli harf sesi için aday üretimler oluşturur (dinleyip seçmek üzere).

Mevcut kayıtlarda ötre sesi ("صُ" = su) harf adı gibi okunuyor. Burada aynı
hece farklı yöntemlerle sentezlenip masaüstüne yazılır; hangisi doğruysa
üretim betiği ona göre güncellenir.

Kullanım: python3 scripts/tts_probe.py
"""

import sys
from pathlib import Path

OUT = Path.home() / "Desktop" / "ses-denemeleri"
LANGUAGE_AR = "ar-XA"
LANGUAGE_TR = "tr-TR"

# (dosya adı, dil, ses, düz metin, ssml)
CANDIDATES = [
    ("1_mevcut_arapca_harf", LANGUAGE_AR, "ar-XA-Chirp3-HD-Fenrir", "صُ", None),
    ("2_arapca_tekrarli", LANGUAGE_AR, "ar-XA-Chirp3-HD-Fenrir", "صُ صُ صُ", None),
    (
        "3_arapca_ipa_fonem",
        LANGUAGE_AR,
        "ar-XA-Wavenet-B",
        "صُ",
        '<speak><phoneme alphabet="ipa" ph="sˤu">صُ</phoneme>'
        '<break time="400ms"/><phoneme alphabet="ipa" ph="sˤu">صُ</phoneme></speak>',
    ),
    ("4_turkce_su", LANGUAGE_TR, "tr-TR-Wavenet-E", "su, su", None),
]


def main() -> int:
    from google.cloud import texttospeech

    client = texttospeech.TextToSpeechClient()
    OUT.mkdir(parents=True, exist_ok=True)
    for name, language, voice_name, text, ssml in CANDIDATES:
        voice = texttospeech.VoiceSelectionParams(
            language_code=language, name=voice_name
        )
        config = texttospeech.AudioConfig(
            audio_encoding=texttospeech.AudioEncoding.MP3,
            speaking_rate=0.85,
        )
        synthesis_input = (
            texttospeech.SynthesisInput(ssml=ssml)
            if ssml
            else texttospeech.SynthesisInput(text=text)
        )
        response = client.synthesize_speech(
            input=synthesis_input, voice=voice, audio_config=config
        )
        dest = OUT / f"{name}.mp3"
        dest.write_bytes(response.audio_content)
        print(f"yazıldı: {dest}")
    return 0


if __name__ == "__main__":
    sys.exit(main())

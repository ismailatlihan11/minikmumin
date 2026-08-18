#!/usr/bin/env python3
"""Prepare the local environment for Kur'an Öğren educational TTS."""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REQUIREMENTS = ROOT / "requirements_audio.txt"
GENERATE = ROOT / "scripts" / "generate_quran_learn_audio.py"


def run(command: list[str]) -> int:
    print("+", " ".join(command), flush=True)
    return subprocess.call(command)


def main() -> int:
    print(f"Python: {sys.version}")
    if sys.version_info < (3, 9):
        print("Python 3.9+ required.", file=sys.stderr)
        return 1
    if not REQUIREMENTS.exists():
        print(f"Missing {REQUIREMENTS}", file=sys.stderr)
        return 1
    pip_status = run(
        [sys.executable, "-m", "pip", "install", "-r", str(REQUIREMENTS)]
    )
    if pip_status != 0:
        print("google-cloud-texttospeech kurulamadı.", file=sys.stderr)
        return pip_status
    check = run([sys.executable, str(GENERATE), "--check-auth"])
    if check != 0:
        print(
            "\nGoogle Cloud TTS erişimi yok. ADC ile giriş yap:\n"
            "  gcloud auth application-default login\n"
            "Credential JSON'u assets/ veya Dart içine koyma.",
            file=sys.stderr,
        )
        return check
    print("\nKurulum tamam. Sıradaki komutlar:")
    print("  python3 scripts/generate_quran_learn_audio.py --test")
    print("  python3 scripts/generate_quran_learn_audio.py --all")
    return 0


if __name__ == "__main__":
    sys.exit(main())
